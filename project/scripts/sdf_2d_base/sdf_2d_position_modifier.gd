class_name SDF2DPositionModifier
extends SDF2DBase
tool

# Public Members
export(DistanceFieldDSL.PushPositionModifierCommand.Type) var modifier_type := DistanceFieldDSL.PushPositionModifierCommand.Type.ELONGATE setget set_modifier_type
export(Vector3) var param := Vector3.ZERO setget set_param

var push_position_modifier_command: DistanceFieldDSL.PushPositionModifierCommand
var pop_position_modifier_command: DistanceFieldDSL.PopPositionModifierCommand

var push_distance_modifier_command: DistanceFieldDSL.PushDistanceModifierCommand
var pop_distance_modifier_command: DistanceFieldDSL.PopDistanceModifierCommand

# Setters
func set_modifier_type(new_modifier_type: int) -> void:
	if modifier_type != new_modifier_type:
		modifier_type = new_modifier_type
		if is_inside_tree():
			modifier_type_changed()

func set_param(new_param: Vector3) -> void:
	if param != new_param:
		param = new_param
		if is_inside_tree():
			param_changed()

# Change Functions
func modifier_type_changed() -> void:
	push_position_modifier_command.type = modifier_type

func param_changed() -> void:
	push_position_modifier_command.params = param
	push_distance_modifier_command.params = Vector2(param[0], param[1])

# Overrides
func _init().() -> void:
	push_position_modifier_command = DistanceFieldDSL.PushPositionModifierCommand.new()
	pop_position_modifier_command = DistanceFieldDSL.PopPositionModifierCommand.new()

	push_distance_modifier_command = DistanceFieldDSL.PushDistanceModifierCommand.new()
	push_distance_modifier_command.type = DistanceFieldDSL.PushDistanceModifierCommand.Type.ELONGATE

	pop_distance_modifier_command = DistanceFieldDSL.PopDistanceModifierCommand.new()

func _enter_tree() -> void:
	modifier_type_changed()
	param_changed()

# Business logic
func build_before_commands(sdf_program: DistanceFieldProgram) -> void:
	if get_child_count() > 0:
		sdf_program.commands.append(push_transform_command)

		if modifier_type == DistanceFieldDSL.PushPositionModifierCommand.Type.ELONGATE:
			sdf_program.commands.append(push_position_modifier_command)
			sdf_program.commands.append(push_distance_modifier_command)
		else:
			sdf_program.commands.append(push_position_modifier_command)

func build_after_commands(sdf_program: DistanceFieldProgram) -> void:
	if get_child_count() > 0:
		if modifier_type == DistanceFieldDSL.PushPositionModifierCommand.Type.ELONGATE:
			sdf_program.commands.append(pop_distance_modifier_command)
			sdf_program.commands.append(pop_position_modifier_command)
		else:
			sdf_program.commands.append(pop_position_modifier_command)

		sdf_program.commands.append(pop_transform_command)
