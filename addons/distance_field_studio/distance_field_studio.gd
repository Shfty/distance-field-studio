class_name DistanceFieldStudioPlugin
extends EditorPlugin
tool

var edited_object_ref: WeakRef = weakref(null)

var distance_field_editor: PackedScene = preload('res://addons/distance_field_studio/scenes/distance_field_editor.tscn')
var distance_field_editor_instance: Node = null

func get_plugin_name() -> String:
	return "Distance Field Studio"

func handles(object: Object) -> bool:
	return object is DistanceField

func edit(object: Object) -> void:
	edited_object_ref = weakref(object)

func make_visible(visible: bool) -> void:
	if visible:
		add_control_to_bottom_panel(distance_field_editor_instance, "Distance Field")
		distance_field_editor_instance.set_distance_field(edited_object_ref.get_ref())
		make_bottom_panel_item_visible(distance_field_editor_instance)
	else:
		remove_control_from_bottom_panel(distance_field_editor_instance)
		distance_field_editor_instance.set_distance_field(null)
		hide_bottom_panel()

func _enter_tree() -> void:
	distance_field_editor_instance = distance_field_editor.instance()

func _exit_tree() -> void:
	remove_control_from_bottom_panel(distance_field_editor_instance)
	distance_field_editor_instance.queue_free()
