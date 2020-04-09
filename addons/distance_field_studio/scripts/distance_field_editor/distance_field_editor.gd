class_name DistanceFieldEditor
extends Control
tool

# Public Members
export(Resource) var shader_library setget set_shader_library
export(Resource) var distance_field setget set_distance_field

# Private Members
var inputs_node: GraphNode
var outputs_node: GraphNode
var cached_node_position: Vector2

# Setters
func set_shader_library(new_shader_library: Resource) -> void:
	if not new_shader_library:
		shader_library = null
	elif new_shader_library is ShaderLibrary and shader_library != new_shader_library:
		shader_library = new_shader_library

func set_distance_field(new_distance_field: Resource) -> void:
	if not new_distance_field:
		distance_field = null
	elif new_distance_field is DistanceField and distance_field != new_distance_field:
		distance_field = new_distance_field
		update_distance_field()

# Getters
func get_tab_container() -> TabContainer:
	if has_node('HBoxContainer/TabContainer'):
		return $HBoxContainer/TabContainer as TabContainer
	return null

func get_active_graph_edit() -> GraphEdit:
	var tab_container = get_tab_container()
	if not tab_container:
		return null

	return tab_container.get_child(tab_container.current_tab)

func get_inputs_node() -> GraphNode:
	if has_node('InsertFunctionDialog'):
		return $HBoxContainer/GraphEdit/Inputs as GraphNode
	return null

func get_outputs_node() -> GraphNode:
	if has_node('HBoxContainer/GraphEdit/Outputs'):
		return $HBoxContainer/GraphEdit/Outputs as GraphNode
	return null

func get_distance_field_instance() -> DistanceFieldInstance:
	if has_node('HBoxContainer/VBoxContainer/ViewportContainer/Viewport/DistanceFieldInstance'):
		return $HBoxContainer/VBoxContainer/ViewportContainer/Viewport/DistanceFieldInstance as DistanceFieldInstance
	return null

# Overrides
func _ready() -> void:
	update_distance_field()

# Business Logic
func update_distance_field() -> void:
	var tab_container = get_tab_container()
	if tab_container:
		for graph_edit in tab_container.get_children():
			graph_edit.set_distance_field(distance_field)

	var distance_field_instance = get_distance_field_instance()
	if distance_field_instance:
		distance_field_instance.set_distance_field(distance_field)

func insert_function(function: GLSLFunction) -> void:
	var active_graph_edit := get_active_graph_edit()
	if not active_graph_edit:
		return

	active_graph_edit.insert_function(function)

func insert_constant(name, type) -> void:
	var active_graph_edit := get_active_graph_edit()
	if not active_graph_edit:
		return

	active_graph_edit.insert_constant(name, type)

func insert_binary_operator(name, operator) -> void:
	var active_graph_edit := get_active_graph_edit()
	if not active_graph_edit:
		return

	active_graph_edit.insert_binary_operator(name, operator)

func insert_vector_break_operator(name, operator) -> void:
	var active_graph_edit := get_active_graph_edit()
	if not active_graph_edit:
		return

	active_graph_edit.insert_vector_break_operator(name, operator)

func insert_vector_make_operator(name, operator) -> void:
	var active_graph_edit := get_active_graph_edit()
	if not active_graph_edit:
		return

	active_graph_edit.insert_vector_make_operator(name, operator)
