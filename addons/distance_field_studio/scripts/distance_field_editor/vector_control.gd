class_name VectorControl
extends CenterContainer
tool

enum Axis {
	HORIZONTAL,
	VERTICAL
}

enum Mode {
	BOOL,
	INTEGER,
	FLOAT
}

# Public Members
export(Axis) var axis = Axis.HORIZONTAL setget set_axis
export(int, 1, 4) var components = 2 setget set_components
export(Mode) var mode := Mode.BOOL setget set_mode

# Private Members
var container: Container = null
var controls := []

# Setters
func set_axis(new_axis: int) -> void:
	if axis != new_axis:
		axis = new_axis
		update_controls()

func set_components(new_components: int) -> void:
	if components != new_components:
		components = new_components
		update_controls()

func set_mode(new_mode: int) -> void:
	if mode != new_mode:
		mode = new_mode
		update_controls()

# Getters
func get_value():
	var value

	match mode:
		Mode.BOOL:
			value = []
		Mode.INTEGER:
			value = PoolIntArray()
		Mode.FLOAT:
			value = PoolRealArray()

	if mode == Mode.BOOL:
		for i in range(0, components):
			value.append(controls[i].pressed)
	else:
		for i in range(0, components):
			value.append(controls[i].value)

	return value

# Overrides
func _init(in_axis: int, in_components: int, in_mode: int) -> void:
	axis = in_axis
	components = in_components
	mode = in_mode
	update_controls()

# Business Logic
func update_controls() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	match axis:
		Axis.HORIZONTAL:
			container = HBoxContainer.new()
		Axis.VERTICAL:
			container = VBoxContainer.new()

	container.size_flags_horizontal = SIZE_EXPAND_FILL
	container.size_flags_vertical = SIZE_EXPAND_FILL

	add_child(container)

	for i in range(0, components):
		var control_target = container
		if axis == Axis.VERTICAL:
			control_target = HBoxContainer.new()
			control_target.size_flags_horizontal = SIZE_EXPAND_FILL
			control_target.size_flags_vertical = SIZE_EXPAND_FILL
			container.add_child(control_target)

		if components > 1:
			var label = Label.new()
			label.rect_min_size.x = 22
			match i:
				0:
					label.text = "X"
				1:
					label.text = "Y"
				2:
					label.text = "Z"
				3:
					label.text = "W"
			control_target.add_child(label)

		var control
		if mode == Mode.BOOL:
			control = CheckBox.new()
		else:
			control = SpinBox.new()
			control.allow_lesser = true
			control.allow_greater = true

			if mode == Mode.INTEGER:
				control.rounded = true
				control.step = 1
			else:
				control.step = 0.1

		control_target.add_child(control)
		controls.append(control)

		rect_min_size = container.rect_size
