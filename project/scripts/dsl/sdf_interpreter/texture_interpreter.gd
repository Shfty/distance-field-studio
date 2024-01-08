class_name TextureInterpreter
extends DistanceFieldInterpreter

class DataBind:
	var property_names: Array
	var data: GPUDataBase

	func _init(in_property_names: Array, in_data) -> void:
		property_names = in_property_names
		data = in_data

# Public Members
var data_texture: DataTexture setget set_data_texture

# Private Members
var bind_data := {
	DistanceFieldDSL.PushTransformCommand: [
		DataBind.new(['transform'], GPUDataTransform2D.new())
	],
	DistanceFieldDSL.ShapeCommand: [
		DataBind.new(['type'], GPUDataByteR.new()),
		DataBind.new(['size'], GPUDataVector2.new()),
		DataBind.new(['color'], GPUDataColor.new()),
		DataBind.new(['gradient'], GPUDataGradient.new()),
		DataBind.new(['modulate_dist'], GPUDataFloatR.new())
	],
	DistanceFieldDSL.PushCSGCommand: [
		DataBind.new(['type'], GPUDataByteR.new()),
		DataBind.new(['distance_smooth_factor', 'color_smooth_factor'], GPUDataFloatRG.new()),
	],
	DistanceFieldDSL.PushDistanceModifierCommand: [
		DataBind.new(['type'], GPUDataByteR.new()),
		DataBind.new(['params'], GPUDataVector2.new()),
	],
	DistanceFieldDSL.PushPositionModifierCommand: [
		DataBind.new(['type'], GPUDataByteR.new()),
		DataBind.new(['params'], GPUDataVector3.new()),
	],
}

var bind_stack_data := {
	DistanceFieldDSL.PopTransformCommand: DistanceFieldDSL.PushTransformCommand,
	DistanceFieldDSL.PopCSGCommand: DistanceFieldDSL.PushCSGCommand,
	DistanceFieldDSL.PopDistanceModifierCommand: DistanceFieldDSL.PushDistanceModifierCommand,
	DistanceFieldDSL.PopPositionModifierCommand: DistanceFieldDSL.PushPositionModifierCommand
}

var binds: Dictionary

var count_data: GPUDataByteR
var command_data: GPUDataByteR

# Setters
func set_data_texture(new_data_texture: DataTexture) -> void:
	if data_texture != new_data_texture:
		data_texture = new_data_texture
		data_texture_changed()

# Change Functions
func before_sdf_program_change() -> void:
	for command_type in bind_data:
		for data_bind in bind_data[command_type]:
			var connections = data_bind.data.get_incoming_connections()
			for connection in connections:
				disconnect_checked(connection.source, connection.signal_name, data_bind.data, connection.signal_name)

func data_texture_changed() -> void:
	pass

# Overrides
func _init() -> void:
	count_data = GPUDataByteR.new()
	command_data = GPUDataByteR.new()

func bind(command: DistanceFieldDSL.Command, property: String, target: GPUDataBase) -> void:
	connect_checked(command, property + '_changed', self, 'write_bound_data', [command, target])

	if not command in binds:
		binds[command] = [target.data_ptr]
	else:
		binds[command].append(target.data_ptr)

	target.write_data(command[property])

func write_bound_data(value, command: DistanceFieldDSL.Command, target: GPUDataBase) -> void:
	for bind in binds[command]:
		target.set_data_by_index(value, bind)

# Business Logic
func interpret() -> void:
	data_texture.disconnect_data()

	# Clear data arrays
	count_data.clear_data()
	command_data.clear_data()

	for command_type in bind_data:
		for data_bind in bind_data[command_type]:
			data_bind.data.clear_data()

	#print("interpreting textures %s" % [sdf_program.commands])
	binds = {}
	var stacks := {}

	for command_type in bind_data:
		if command_type in bind_stack_data.values():
			stacks[command_type] = []

	for i in range(0, sdf_program.commands.size()):
		var command = sdf_program.commands[i]
		command_data.append_data(command.get_command_type())

		if not command.get_script() in bind_data and not command.get_script() in bind_stack_data:
			printerr('Texture interpret failed: Unrecognized command type %s' % [command.get_script()])
			return

		var command_data_bind = null
		if command.get_script() in bind_data:
			command_data_bind = bind_data[command.get_script()]
		else:
			command_data_bind = bind_data[bind_stack_data[command.get_script()]]

		var target_command = command
		if command.get_script() in bind_stack_data.values():
			stacks[command.get_script()].append(command)
		elif command.get_script() in bind_stack_data.keys():
			stacks[bind_stack_data[command.get_script()]].pop_back()
			if stacks[bind_stack_data[command.get_script()]].size() > 0:
				target_command = stacks[bind_stack_data[command.get_script()]].back()
			else:
				target_command = null

		if target_command:
			for data_bind in command_data_bind:
				for property_name in data_bind.property_names:
					bind(target_command, property_name, data_bind.data)

	# Populate count data
	count_data.resize_data(bind_data.size() + 1)
	count_data.write_data(sdf_program.commands.size())

	for command_type in bind_data:
		count_data.write_data(bind_data[command_type][0].data.data.size())

	var gpu_data := [count_data, command_data]
	for command_type in bind_data:
		for data_bind in bind_data[command_type]:
			gpu_data.append(data_bind.data)

	data_texture.gpu_data = gpu_data
	data_texture.full_update()
	data_texture.connect_data()
