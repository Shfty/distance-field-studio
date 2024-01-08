class_name SDF2DMeshInstance2D
extends MeshInstance2D
tool

enum DrawMode {
	NORMAL,
	DEBUG
}

# Public Members
export(Resource) var sdf_program setget set_sdf_program

export(DrawMode) var draw_mode := DrawMode.NORMAL setget set_draw_mode

export(Dictionary) var uniforms := {
	'draw_mode': 0,
	'normal_mode': 0,
	'anti_alias_gradient': 1.0,
	'visual_sine_frequency': 100,
	'visual_surface_size': 1.0,
	'visual_cutoff': 0.5,
	'visual_min': -0.25,
	'visual_max': 0.5,
	'raw_min': 0.0,
	'raw_max': 1.0,
	'raw_flip': 1.0
} setget set_uniforms

export(Vector2) var bounds_padding := Vector2.ZERO setget set_bounds_padding

# Private Members
var sdf_material: SDF2DMaterialBase = null
var sdf_mesh: SDF2DMesh = null

# Setters
func set_sdf_program(new_sdf_program: Resource) -> void:
	if sdf_program != new_sdf_program:
		sdf_program = new_sdf_program
		if is_inside_tree():
			update_sdf_program()

func set_draw_mode(new_draw_mode: int) -> void:
	if draw_mode != new_draw_mode:
		draw_mode = new_draw_mode
		if is_inside_tree():
			update_material()
			update_sdf_program()
			update_uniforms()

func set_uniforms(new_uniforms: Dictionary) -> void:
	if uniforms != new_uniforms:
		uniforms = new_uniforms
		if is_inside_tree():
			update_uniforms()

func set_bounds_padding(new_bounds_padding: Vector2) -> void:
	if bounds_padding != new_bounds_padding:
		bounds_padding = new_bounds_padding
		if is_inside_tree():
			update_bounds_padding()

# Update Functions
func update_material() -> void:
	match draw_mode:
		DrawMode.NORMAL:
			sdf_material = SDF2DMaterial.new()
		DrawMode.DEBUG:
			sdf_material = SDF2DMaterialDebug.new()
	set_material(sdf_material)

func update_mesh() -> void:
	sdf_mesh = SDF2DMesh.new()
	set_mesh(sdf_mesh)

func update_sdf_program() -> void:
	sdf_material.sdf_program = sdf_program
	sdf_mesh.sdf_program = sdf_program

func update_uniforms() -> void:
	if not sdf_program:
		return

	for uniform in uniforms:
		# print("%s setting %s to %s" % [resource_name, uniform, sdf_program.uniforms[uniform]])
		sdf_material.set_shader_param(uniform, uniforms[uniform])

func update_bounds_padding() -> void:
	sdf_mesh.bounds_padding = bounds_padding

# Overrides
func _init() -> void:
	update_material()
	update_mesh()
