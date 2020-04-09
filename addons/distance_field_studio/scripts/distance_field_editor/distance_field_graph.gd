extends GraphEdit
tool

# Public Members
export(Resource) var distance_field: Resource setget set_distance_field

export(String) var target_resource = 'distance_field_function'

export(Array, String) var input_names := [
	'Position'
]

export(Array, String) var input_types := [
	'vec3'
]

export(Array, String) var input_glsl := [
	'IN_POSITION'
]

export(Array, String) var output_names := [
	'Distance',
	'Normal',
	'Tangent',
	'Binormal',
]

export(Array, String) var output_types := [
	'float',
	'vec3',
	'vec3',
	'vec3',
]

export(Array, String) var output_properties := [
	'signed_distance_function',
	'normal_function',
	'tangent_function',
	'binormal_function'
]

export(Array, String) var output_glsl := [
	'OUT_DISTANCE = %s;',
	'OUT_NORMAL = %s;',
	'OUT_TANGENT = %s;',
	'OUT_BINORMAL = %s;'
]

# Private Members
var inputs_node: GraphNode
var outputs_node: GraphNode
var cached_mouse_position: Vector2

# Setters
func set_distance_field(new_distance_field: Resource) -> void:
	if not new_distance_field:
		distance_field = null
	elif new_distance_field is DistanceField and distance_field != new_distance_field:
		distance_field = new_distance_field

# Overrides
func _ready() -> void:
	for child in get_children():
		if child is GraphNode:
			remove_child(child)
			child.queue_free()

	# Create input node
	if input_names.size() > 0:
		inputs_node = create_graph_node("Inputs", false)

		for i in range(0, input_names.size()):
			create_output_pin(inputs_node, i, input_names[i], input_types[i])

		inputs_node.set_offset(Vector2(20, 60))
		inputs_node.set_meta('glsl_code', input_glsl)

		add_child(inputs_node)

	# Create output node
	if output_names.size() > 0:
		outputs_node = create_graph_node("Outputs", false)

		for i in range(0, output_names.size()):
			create_input_pin(outputs_node, i, output_names[i], output_types[i], true)

		outputs_node.set_offset(Vector2(500, 60))

		add_child(outputs_node)

	# Register valid input types
	for key in DistanceFieldUtil.GLSL_TYPE_STRING_MAP:
		add_valid_connection_type(-1, key)
		add_valid_connection_type(key, -1)

	# Connect signals
	connect('connection_request', self, 'connection_request')
	connect('disconnection_request', self, 'disconnection_request')
	connect('delete_nodes_request', self, 'delete_nodes_request')

func create_output_pin(node: GraphNode, index: int, name: String, type_string: String):
	var label = Label.new()
	label.text = name
	node.add_child(label)

	var type_enum = DistanceFieldUtil.glsl_type_string_to_enum(type_string)
	var type_color = DistanceFieldUtil.glsl_type_enum_to_color(type_enum)
	node.set_slot(index, false, -1, Color.black, true, type_enum, type_color)

func create_input_pin(node: GraphNode, index: int, name: String, type_string: String, optional: bool):
	var label = Label.new()
	label.text = name
	label.set_meta('optional', optional)
	node.add_child(label)

	var type_enum = DistanceFieldUtil.glsl_type_string_to_enum(type_string)
	var type_color = DistanceFieldUtil.glsl_type_enum_to_color(type_enum)
	node.set_slot(index, true, type_enum, type_color, false, -1, Color.black)

func can_drop_data(position: Vector2, data) -> bool:
	if data is Dictionary and 'palette_data' in data:
		return true
	return false

func drop_data(position: Vector2, data) -> void:
	cached_mouse_position = position
	var palette_data = data['palette_data']
	var data_type = palette_data[0]

	match data_type:
		'constant':
			insert_constant(palette_data[1], palette_data[2])
		'binary_operator':
			insert_binary_operator(palette_data[1], palette_data[2])
		'vector_break_operator':
			insert_vector_break_operator(palette_data[1], palette_data[2])
		'vector_make_operator':
			insert_vector_make_operator(palette_data[1], palette_data[2])
		'glsl_function':
			insert_function(palette_data[1])
		_:
			print(palette_data)

# Slots
func connection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	var from_node = get_node(from)
	var to_node = get_node(to)

	var from_type = from_node.get_slot_type_right(from_slot)
	var to_type = to_node.get_slot_type_left(to_slot)

	if not from_type == to_type and from_type != -1 and to_type != -1:
		return

	connect_node(from, from_slot, to, to_slot)
	evaluate_graph()

func disconnection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	disconnect_node(from, from_slot, to, to_slot)
	evaluate_graph()

func delete_nodes_request() -> void:
	var connections := get_connection_list()
	for child in get_children():
		if child is GraphNode and child.selected:
			if child == inputs_node or child == outputs_node:
				continue

			for connection in connections:
				if connection.from == child.get_name() or connection.to == child.get_name():
					disconnect_node(
						connection.from,
						connection.from_port,
						connection.to,
						connection.to_port
					)

			remove_child(child)
			child.queue_free()

	evaluate_graph()

func close_request(node: GraphNode) -> void:
	remove_child(node)
	node.queue_free()

func create_graph_node(title: String, show_close: bool) -> GraphNode:
	var graph_node := GraphNode.new()
	graph_node.set_title(title)
	graph_node.set_show_close_button(show_close)
	if show_close:
		graph_node.connect('close_request', self, 'close_request', [graph_node])

	var target_position = cached_mouse_position + get_scroll_ofs()
	target_position /= get_zoom()
	graph_node.set_offset(target_position)

	return graph_node

func insert_constant(name: String, type: int) -> void:
	var graph_node := create_graph_node("const " + name, true)
	var control = DistanceFieldUtil.create_control_for_glsl_type(type)
	if control:
		graph_node.add_child(control)

	var color = DistanceFieldUtil.glsl_type_enum_to_color(type)
	graph_node.set_slot(0, false, -1, Color.black, true, type, color)
	graph_node.set_meta('constant', DistanceFieldUtil.glsl_type_enum_to_string(type))

	add_child(graph_node)

func insert_function(function: GLSLFunction) -> void:
	var graph_node := create_graph_node(function.get_name(), true)

	var return_type_enum = DistanceFieldUtil.glsl_type_string_to_enum(function.return_type)
	var return_color = DistanceFieldUtil.glsl_type_enum_to_color(return_type_enum)

	var glsl_code = function.name + "("

	for i in range(0, function.params.size()):
		var param = function.params[i]
		var label = Label.new()
		label.text = param.get_name()
		graph_node.add_child(label)

		var type = DistanceFieldUtil.glsl_type_string_to_enum(param.type)
		var color = DistanceFieldUtil.glsl_type_enum_to_color(type)
		graph_node.set_slot(i, true, type, color, i == 0, return_type_enum, return_color)

		glsl_code += "%s"
		if i != function.params.size() - 1:
			glsl_code += ", "

	glsl_code += ")"
	graph_node.set_meta('glsl_code', [glsl_code])

	add_child(graph_node)

func insert_binary_operator(name: String, operator: String) -> void:
	var graph_node := create_graph_node(name, true)

	var lhs_label = Label.new()
	lhs_label.text = "LHS"

	var rhs_label = Label.new()
	rhs_label.text = "RHS"

	graph_node.add_child(lhs_label)
	graph_node.add_child(rhs_label)

	graph_node.set_slot(0, true, -1, Color.white, true, -1, Color.white)
	graph_node.set_slot(1, true, -1, Color.white, false, -1, Color.black)
	graph_node.set_meta('binary_operator', operator)

	add_child(graph_node)

func insert_vector_break_operator(name: String, type_string: String) -> void:
	var graph_node := create_graph_node(name, true)

	var components := -1
	if type_string.find('2') != -1:
		components = 2
	elif type_string.find('3') != -1:
		components = 3
	elif type_string.find('4') != -1:
		components = 4
	else:
		return

	var type = DistanceFieldUtil.glsl_type_string_to_enum(type_string)
	var color = DistanceFieldUtil.glsl_type_enum_to_color(type)
	var component_type = DistanceFieldUtil.glsl_type_enum_to_component_type(type)
	var component_color = DistanceFieldUtil.glsl_type_enum_to_color(component_type)

	for i in range(0, components):
		var label = Label.new()
		label.align = Label.ALIGN_RIGHT
		match i:
			0:
				label.text = "X"
			1:
				label.text = "Y"
			2:
				label.text = "Z"
			3:
				label.text = "W"
		graph_node.add_child(label)
		graph_node.set_slot(i, i == 0, type, color, true, component_type, component_color)

	graph_node.set_meta('vector_break_operator', [type_string, components])

	add_child(graph_node)

func insert_vector_make_operator(name: String, type_string: String) -> void:
	var graph_node := create_graph_node(name, true)

	var components := -1
	if type_string.find('2') != -1:
		components = 2
	elif type_string.find('3') != -1:
		components = 3
	elif type_string.find('4') != -1:
		components = 4
	else:
		return

	var type = DistanceFieldUtil.glsl_type_string_to_enum(type_string)
	var color = DistanceFieldUtil.glsl_type_enum_to_color(type)
	var component_type = DistanceFieldUtil.glsl_type_enum_to_component_type(type)
	var component_color = DistanceFieldUtil.glsl_type_enum_to_color(component_type)

	for i in range(0, components):
		var label = Label.new()
		match i:
			0:
				label.text = "X"
			1:
				label.text = "Y"
			2:
				label.text = "Z"
			3:
				label.text = "W"
		graph_node.add_child(label)
		graph_node.set_slot(i, true, component_type, component_color, i == 0, type, color)

	graph_node.set_meta('vector_make_operator', [type_string, components])
	add_child(graph_node)

func evaluate_graph() -> void:
	if not distance_field:
		printerr("Unable to evaluate graph: Distance field missing")
		return

	var target = distance_field.get(target_resource)
	if not target:
		printerr('Unable to evaluate graph: Distance field %s missing' % target_resource)
		return

	var distance_val = get_input_value(outputs_node, 0)

	set_connections_active(false)

	for i in range(0, output_properties.size()):
		var val = get_input_value(outputs_node, i)

		if not val or 'Null' in val:
			target.set(output_properties[i], '')
		else:
			target.set(output_properties[i], output_glsl[i] % get_input_value(outputs_node, i))

func set_connections_active(active: bool) -> void:
	var connections = get_connection_list()
	for connection in connections:
		set_connection_activity(connection.from, connection.from_port, connection.to, connection.to_port, 1.0 if active else 0.0)

func get_connection_input_node(node: GraphNode, index: int) -> Array:
	for connection in get_connection_list():
		if connection.to == node.get_name() and connection.to_port == index:
			return [get_node(connection.from), connection.from_port]
	return [null, -1]

func get_connection_input_nodes(node: GraphNode) -> Array:
	if not node:
		return []

	var input_nodes := []
	for i in range(0, node.get_connection_input_count()):
		input_nodes.append(get_connection_input_node(node, i))

	return input_nodes

func get_input_value(node: GraphNode, index: int):
	var connection_input_data = get_connection_input_node(node, index)

	var connections = get_connection_list()
	for connection in connections:
		if connection.to == node.get_name() and connection.to_port == index:
			set_connection_activity(connection.from, connection.from_port, connection.to, connection.to_port, 1.0)

	var input_node = connection_input_data[0]
	var output_index = connection_input_data[1]
	if input_node:
		return get_node_output(input_node)[output_index]
	return null

func get_node_output(node: GraphNode) -> Array:
	if node.has_meta('glsl_code'):
		return get_output_glsl_code(node)
	elif node.has_meta('binary_operator'):
		return get_output_binary_operator(node)
	elif node.has_meta('vector_break_operator'):
		return get_output_vector_break_operator(node)
	elif node.has_meta('vector_make_operator'):
		return get_output_vector_make_operator(node)
	elif node.has_meta('constant'):
		return get_output_constant(node)

	return []

func get_output_glsl_code(node: GraphNode) -> Array:
	var node_glsl = node.get_meta('glsl_code')
	var glsl := []
	for i in range(0, node_glsl.size()):
		var replace := []
		var glsl_code := node.get_meta('glsl_code')[i] as String
		for i in range(0, glsl_code.count('%')):
			replace.append(get_input_value(node, i))
		glsl.append(glsl_code % replace)
	return glsl

func get_output_binary_operator(node: GraphNode) -> Array:
	var lhs_input = get_input_value(node, 0)
	var rhs_input = get_input_value(node, 1)
	return ["(%s " + node.get_meta('binary_operator') + " %s)" % [lhs_input, rhs_input]]

func get_output_vector_break_operator(node: GraphNode) -> Array:
	var input = get_input_value(node, 0)
	return [
		"%s.x" % input,
		"%s.y" % input,
		"%s.z" % input,
		"%s.w" % input
	]

func get_output_vector_make_operator(node: GraphNode) -> Array:
	var meta = node.get_meta('vector_make_operator')
	var type_string = meta[0]
	var components = meta[1]
	print(meta)
	var out_string = "%s(" % [type_string]
	for i in range(0, components):
		var value = get_input_value(node, i)
		if value:
			out_string += get_input_value(node, i)
		else:
			out_string += "Null"

		if i != components - 1:
			out_string += ", "
	out_string += ")"
	return [out_string]

func get_output_constant(node: GraphNode) -> Array:
	var type_string = node.get_meta('constant')
	var value = node.get_child(0).get_value()
	match typeof(value):
		TYPE_ARRAY:
			match value.size():
				1: value = String(value[0]).to_lower()
				2: value = "%s(%s, %s)" % [
					type_string,
					String(value[0]).to_lower(),
					String(value[1]).to_lower()
				]
				3: value = "%s(%s, %s, %s)" % [
					type_string,
					String(value[0]).to_lower(),
					String(value[1]).to_lower(),
					String(value[2]).to_lower()
				]
				4: value = "%s(%s, %s, %s, %s)" % [
					type_string,
					String(value[0]).to_lower(),
					String(value[1]).to_lower(),
					String(value[2]).to_lower()
				]
		TYPE_INT_ARRAY:
			match value.size():
				1: value = String(value[0])
				2: value = "%s(%s, %s)" % [type_string, value[0], value[1]]
				3: value = "%s(%s, %s, %s)" % [type_string, value[0], value[1], value[2]]
				4: value = "%s(%s, %s, %s, %s)" % [type_string, value[0], value[1], value[2]]
		TYPE_REAL_ARRAY:
			match value.size():
				1:
					value = String(value[0])
					if not '.' in value:
						value = String(value).pad_decimals(1)
				2: value = "%s(%s, %s)" % [
					type_string,
					String(value[0]).pad_decimals(1),
					String(value[1]).pad_decimals(1)
				]
				3: value = "%s(%s, %s, %s)" % [
					type_string,
					String(value[0]).pad_decimals(1),
					String(value[1]).pad_decimals(1),
					String(value[2]).pad_decimals(1)
				]
				4: value = "%s(%s, %s, %s, %s)" % [
					type_string,
					String(value[0]).pad_decimals(1),
					String(value[1]).pad_decimals(1),
					String(value[2]).pad_decimals(1)
				]
	return [value]
