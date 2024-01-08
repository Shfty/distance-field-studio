class_name SDF2DDistanceModifier
extends SDF2DBase
tool

# Public Members
export(DistanceFieldDSL.PushDistanceModifierCommand.Type) var modifier_type := DistanceFieldDSL.PushDistanceModifierCommand.Type.ROUND setget set_modifier_type
export(float,0,1,0.01) var radius := 0.25 setget set_radius

# Private Members
var push_distance_modifier_command: DistanceFieldDSL.PushDistanceModifierCommand
var pop_distance_modifier_command: DistanceFieldDSL.PopDistanceModifierCommand

# Setters
func set_modifier_type(new_modifier_type: int) -> void:
	if modifier_type != new_modifier_type:
		modifier_type = new_modifier_type
		if is_inside_tree():
			modifier_type_changed()

func set_radius(new_radius: float) -> void:
	if radius != new_radius:
		radius = new_radius
		if is_inside_tree():
			radius_changed()

# Change Functions
func modifier_type_changed() -> void:
	push_distance_modifier_command.type = modifier_type

func radius_changed() -> void:
	push_distance_modifier_command.params = Vector2(radius, 0.0)

# Overrides
func _init().() -> void:
	push_distance_modifier_command = DistanceFieldDSL.PushDistanceModifierCommand.new()
	pop_distance_modifier_command = DistanceFieldDSL.PopDistanceModifierCommand.new()

func _enter_tree() -> void:
	modifier_type_changed()
	radius_changed()

# Business logic
func build_before_commands(sdf_program: DistanceFieldProgram) -> void:
	if get_child_count() > 0:
		sdf_program.commands.append(push_transform_command)
		sdf_program.commands.append(push_distance_modifier_command)

func build_after_commands(sdf_program: DistanceFieldProgram) -> void:
	if get_child_count() > 0:
		sdf_program.commands.append(pop_distance_modifier_command)
		sdf_program.commands.append(pop_transform_command)
