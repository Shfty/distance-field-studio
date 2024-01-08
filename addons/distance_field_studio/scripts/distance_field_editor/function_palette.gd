extends Control
tool

signal function_selected(function)
signal constant_selected(name, type)
signal binary_operator_selected(name, operator)
signal vector_break_operator_selected(name, operator)
signal vector_make_operator_selected(name, operator)

var popup_menus := []

func get_vbox() -> VBoxContainer:
	return $VBoxContainer as VBoxContainer

func _ready() -> void:
	populate_function_list()

func populate_function_list() -> void:
	var distance_field_editor := get_owner() as DistanceFieldEditor
	if not distance_field_editor:
		return

	var shader_library = distance_field_editor.shader_library
	if not shader_library:
		return

	var vbox = get_vbox()
	for child in vbox.get_children():
		vbox.remove_child(child)
		child.queue_free()

	populate_constants(vbox, "Constants", DistanceFieldUtil.GLSL_TYPE_STRING_MAP)
	populate_binary_operators(vbox, "Binary Operators", {
		"+": "Add",
		"-": "Subtract",
		"*": "Multiply",
		"/": "Divide"
	})
	populate_vector_make_operators(vbox, "Make Vector", DistanceFieldUtil.GLSL_VECTOR_TYPES)
	populate_vector_break_operators(vbox, "Break Vector", DistanceFieldUtil.GLSL_VECTOR_TYPES)

	for function_category in shader_library.function_category_names:
		var category_name = shader_library.function_category_names[function_category]
		populate_glsl_functions(vbox, category_name, shader_library.functions[function_category])

func create_category_control(parent: Control, title: String) -> Array:
	var popup_menu = Panel.new()
	popup_menu.visible = false
	popup_menus.append(popup_menu)
	get_owner().call_deferred('add_child', popup_menu)

	var grid_container = GridContainer.new()
	grid_container.margin_left = 4
	grid_container.margin_top = 4
	grid_container.columns = 4
	grid_container.name = "GridContainer"
	grid_container.size_flags_horizontal = SIZE_EXPAND_FILL
	grid_container.size_flags_vertical = SIZE_EXPAND_FILL
	popup_menu.add_child(grid_container)

	var button = Button.new()
	button.rect_min_size.y = 40
	button.focus_mode = Control.FOCUS_NONE
	button.set_text(title)
	button.size_flags_vertical = SIZE_EXPAND_FILL
	button.connect('mouse_entered', self, 'set_popup_menu_visible', [[button, popup_menu]])

	parent.add_child(button)

	return [button, popup_menu]

func popup_menu_add_item(popup_menu: Control, title: String, metadata) -> void:
	var button = PaletteButton.new()
	button.title = title
	button.metadata = {'palette_data': metadata}
	button.connect('drag_started', self, 'hide_popup_menus')
	popup_menu.get_node('GridContainer').add_child(button)

func set_popup_menu_visible(controls: Array) -> void:
	var popup_menu = controls[1]
	position_popup_menu(controls)
	for comp_menu in popup_menus:
		comp_menu.visible = comp_menu == popup_menu

func hide_popup_menus() -> void:
	for menu in popup_menus:
		menu.visible = false

func position_popup_menu(controls: Array) -> void:
	var button = controls[0]
	var popup_menu = controls[1]
	popup_menu.rect_size = popup_menu.get_child(0).rect_size + (Vector2.ONE * 8)
	popup_menu.rect_global_position.x = rect_global_position.x - popup_menu.rect_size.x
	popup_menu.rect_global_position.y = button.rect_global_position.y - (popup_menu.rect_size.y - button.rect_size.y) * 0.5

	var popup_rect = popup_menu.get_global_rect()
	var owner_rect = get_owner().get_global_rect()

	if popup_rect.end.y > owner_rect.end.y:
		var delta = popup_rect.end.y - owner_rect.end.y
		popup_menu.rect_position.y -= abs(popup_rect.end.y - owner_rect.end.y)

func populate_binary_operators(parent: Control, title: String, constants: Dictionary) -> void:
	var controls = create_category_control(parent, title)
	var popup_menu = controls[1]

	for constant in constants:
		popup_menu_add_item(popup_menu, constants[constant], ['binary_operator', constants[constant], constant])

	call_deferred('position_popup_menu', controls)

func populate_vector_break_operators(parent: Control, title: String, types: Array) -> void:
	var controls = create_category_control(parent, title)
	var popup_menu = controls[1]

	for type in types:
		var type_string = DistanceFieldUtil.glsl_type_enum_to_string(type)
		var op_title = "Break %s" % type_string
		popup_menu_add_item(popup_menu, op_title, ['vector_break_operator', op_title, type_string])

	call_deferred('position_popup_menu', controls)

func populate_vector_make_operators(parent: Control, title: String, types: Array) -> void:
	var controls = create_category_control(parent, title)
	var popup_menu = controls[1]

	for type in types:
		var type_string = DistanceFieldUtil.glsl_type_enum_to_string(type)
		var op_title = "Make %s" % type_string
		popup_menu_add_item(popup_menu, op_title, ['vector_make_operator', op_title, type_string])

	call_deferred('position_popup_menu', controls)

func populate_constants(parent: Control, title: String, constants: Dictionary) -> void:
	var controls = create_category_control(parent, title)
	var popup_menu = controls[1]

	for constant in constants:
		popup_menu_add_item(popup_menu, constants[constant], ['constant', constants[constant], constant])

	call_deferred('position_popup_menu', controls)

func populate_glsl_functions(parent: Control, title: String, glsl_functions: Array) -> void:
	var controls = create_category_control(parent, title)
	var popup_menu = controls[1]

	for glsl_function in glsl_functions:
		popup_menu_add_item(popup_menu, glsl_function.get_name(), ['glsl_function', glsl_function])

	call_deferred('position_popup_menu', controls)
