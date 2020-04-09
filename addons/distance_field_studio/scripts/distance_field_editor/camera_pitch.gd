extends Spatial
tool

const SENSITIVITY = 0.01

func viewport_input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return

	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		rotate(Vector3.RIGHT, -event.relative.y * SENSITIVITY)
		rotation_degrees.x = clamp(rotation_degrees.x, -90, 90)
