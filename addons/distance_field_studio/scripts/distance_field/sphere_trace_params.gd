class_name SphereTraceParams
extends Resource
tool

signal max_steps_changed()
signal over_relax_factor_changed()
signal anti_alias_gradient_changed()
signal hollow_changed()
signal force_hit_changed()
signal continuity_iterations_changed()
signal continuity_threshold_changed()
signal draw_steps_changed()
signal step_min_color_changed()
signal step_mid_color_changed()
signal step_max_color_changed()

export(int, 0, 4096) var max_steps := 128 setget set_max_steps
export(float, 1, 2) var over_relax_factor := 1.4 setget set_over_relax_factor
export(float, 0, 16) var anti_alias_gradient := 1.0 setget set_anti_alias_gradient
export(bool) var hollow := true setget set_hollow
export(bool) var force_hit := false setget set_force_hit
export(int, 0, 16) var continuity_iterations := 3 setget set_continuity_iterations
export(float, 0.001, 1.0) var continuity_threshold := 0.001 setget set_continuity_threshold

export(bool) var draw_steps := false setget set_draw_steps
export(Color) var step_min_color := Color.black setget set_step_min_color
export(Color) var step_mid_color := Color.darkgray setget set_step_mid_color
export(Color) var step_max_color := Color.white setget set_step_max_color

func set_max_steps(new_max_steps: int) -> void:
	if max_steps != new_max_steps:
		max_steps = new_max_steps
		emit_signal('max_steps_changed')

func set_over_relax_factor(new_over_relax_factor: float) -> void:
	if over_relax_factor != new_over_relax_factor:
		over_relax_factor = new_over_relax_factor
		emit_signal('over_relax_factor_changed')

func set_anti_alias_gradient(new_anti_alias_gradient: float) -> void:
	if anti_alias_gradient != new_anti_alias_gradient:
		anti_alias_gradient = new_anti_alias_gradient
		emit_signal('anti_alias_gradient_changed')

func set_hollow(new_hollow: bool) -> void:
	if hollow != new_hollow:
		hollow = new_hollow
		emit_signal('hollow_changed')

func set_force_hit(new_force_hit: bool) -> void:
	if force_hit != new_force_hit:
		force_hit = new_force_hit
		emit_signal('force_hit_changed')

func set_continuity_iterations(new_continuity_iterations: int) -> void:
	if continuity_iterations != new_continuity_iterations:
		continuity_iterations != new_continuity_iterations
		emit_signal('continuity_iterations_changed')

func set_continuity_threshold(new_continuity_threshold: float) -> void:
	if continuity_threshold != new_continuity_threshold:
		continuity_threshold = new_continuity_threshold
		emit_signal('continuity_threshold_changed')

func set_draw_steps(new_draw_steps: bool) -> void:
	if draw_steps != new_draw_steps:
		draw_steps = new_draw_steps
		emit_signal('draw_steps_changed')

func set_step_min_color(new_step_min_color: Color) -> void:
	if step_min_color != new_step_min_color:
		step_min_color = new_step_min_color
		emit_signal('step_min_color_changed')

func set_step_mid_color(new_step_mid_color: Color) -> void:
	if step_mid_color != new_step_mid_color:
		step_mid_color = new_step_mid_color
		emit_signal('step_mid_color_changed')

func set_step_max_color(new_step_max_color: Color) -> void:
	if step_max_color != new_step_max_color:
		step_max_color = new_step_max_color
		emit_signal('step_max_color_changed')

func _init() -> void:
	if resource_name == "":
		resource_name = "Sphere Trace Params"
