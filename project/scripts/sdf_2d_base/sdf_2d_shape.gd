class_name SDF2DShape
extends SDF2DBase
tool

# Public Members
export(DistanceFieldDSL.ShapeCommand.Type) var sdf_type := DistanceFieldDSL.ShapeCommand.Type.CIRCLE setget set_sdf_type
export(Vector2) var size := Vector2.ONE setget set_size
export(Color) var color := Color.white setget set_color
export(Gradient) var gradient setget set_gradient
export(float) var modulate_dist := 1.0 setget set_modulate_dist

# Private Members
var shape_command: DistanceFieldDSL.ShapeCommand

# Setters
func set_sdf_type(new_sdf_type: int) -> void:
	if sdf_type != new_sdf_type:
		sdf_type = new_sdf_type
		if is_inside_tree():
			sdf_type_changed()

func set_size(new_size: Vector2) -> void:
	if size != new_size:
		size = new_size
		if is_inside_tree():
			size_changed()

func set_color(new_color: Color) -> void:
	if color != new_color:
		color = new_color
		if is_inside_tree():
			color_changed()

func set_gradient(new_gradient: Gradient) -> void:
	if not new_gradient:
		new_gradient = Gradient.new()
		new_gradient.offsets = PoolRealArray([0.0, 0.4, 0.5, 0.6, 1.0])
		new_gradient.colors = PoolColorArray([Color.white, Color.blue, Color.black, Color.red, Color.white])

	if gradient != new_gradient:
		gradient = new_gradient
		if is_inside_tree():
			gradient_changed()


func set_modulate_dist(new_modulate_dist: float) -> void:
	if modulate_dist != new_modulate_dist:
		modulate_dist = new_modulate_dist
		if is_inside_tree():
			modulate_dist_changed()


# Change Functions
func sdf_type_changed() -> void:
	shape_command.type = sdf_type

func size_changed() -> void:
	shape_command.size = size

func color_changed() -> void:
	shape_command.color = color

func gradient_changed() -> void:
	shape_command.gradient = gradient

func modulate_dist_changed() -> void:
	shape_command.modulate_dist = modulate_dist

# Overrides
func _init().() -> void:
	shape_command = DistanceFieldDSL.ShapeCommand.new()

func _enter_tree() -> void:
	for child in get_children():
		if child.has_meta('sdf_2d_shape_child'):
			remove_child(child)
			child.queue_free()

	var rect = RectangleShape2D.new()
	rect.extents = size

	var collision_shape = CollisionShape2D.new()
	collision_shape.set_shape(rect)
	collision_shape.self_modulate = Color(1, 1, 1, 0)

	var area = Area2D.new()
	area.set_meta('sdf_2d_shape_child', true)
	area.add_child(collision_shape)
	add_child(area)

	sdf_type_changed()
	size_changed()
	color_changed()
	gradient_changed()
	modulate_dist_changed()

# Business logic
func build_after_commands(sdf_program: DistanceFieldProgram) -> void:
	sdf_program.commands.append(push_transform_command)
	sdf_program.commands.append(shape_command)
	sdf_program.commands.append(pop_transform_command)
