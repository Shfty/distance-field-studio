class_name SDF2DCSG
extends SDF2DBase
tool

# Public Members
export(DistanceFieldDSL.PushCSGCommand.Type) var csg_type := DistanceFieldDSL.PushCSGCommand.Type.UNION setget set_csg_type
export(float,0,1,0.01) var distance_smooth_factor := 0.0 setget set_distance_smooth_factor
export(float,0,1,0.01) var color_smooth_factor := 0.0 setget set_color_smooth_factor

var push_csg_command: DistanceFieldDSL.PushCSGCommand
var pop_csg_command: DistanceFieldDSL.PopCSGCommand

# Setters
func set_csg_type(new_csg_type: int) -> void:
	if csg_type != new_csg_type:
		csg_type = new_csg_type
		if is_inside_tree():
			csg_type_changed()

func set_distance_smooth_factor(new_distance_smooth_factor: float) -> void:
	if distance_smooth_factor != new_distance_smooth_factor:
		distance_smooth_factor = new_distance_smooth_factor
		if is_inside_tree():
			distance_smooth_factor_changed()

func set_color_smooth_factor(new_color_smooth_factor: float) -> void:
	if color_smooth_factor != new_color_smooth_factor:
		color_smooth_factor = new_color_smooth_factor
		if is_inside_tree():
			color_smooth_factor_changed()

# Change Functions
func csg_type_changed() -> void:
	push_csg_command.type = csg_type

func distance_smooth_factor_changed() -> void:
	push_csg_command.distance_smooth_factor = distance_smooth_factor

func color_smooth_factor_changed() -> void:
	push_csg_command.color_smooth_factor = color_smooth_factor

# Overrides
func _init().() -> void:
	push_csg_command = DistanceFieldDSL.PushCSGCommand.new()
	pop_csg_command = DistanceFieldDSL.PopCSGCommand.new()

func _enter_tree() -> void:
	csg_type_changed()
	distance_smooth_factor_changed()
	color_smooth_factor_changed()

# Business logic
func build_before_commands(sdf_program: DistanceFieldProgram) -> void:
	if get_child_count() > 0:
		sdf_program.commands.append(push_transform_command)
		sdf_program.commands.append(push_csg_command)

func build_after_commands(sdf_program: DistanceFieldProgram) -> void:
	if get_child_count() > 0:
		sdf_program.commands.append(pop_csg_command)
		sdf_program.commands.append(pop_transform_command)
