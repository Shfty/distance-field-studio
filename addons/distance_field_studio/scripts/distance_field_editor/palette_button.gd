class_name PaletteButton
extends Button
tool

signal drag_started()

export(String) var title setget set_title

var metadata = null

func set_title(new_title: String) -> void:
	if title != new_title:
		title = new_title
		set_text(title)

func _init() -> void:
	rect_min_size = Vector2(120, 40)

func get_drag_data(position: Vector2):
	set_drag_preview(make_drag_preview(position))
	emit_signal("drag_started")
	return metadata

func make_drag_preview(position: Vector2) -> Control:
	var wrapper = Control.new()
	var preview = self.duplicate()
	wrapper.add_child(preview)
	preview.rect_position = -get_local_mouse_position()
	return wrapper
