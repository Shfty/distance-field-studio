class_name SDF2DDebugger
extends MeshInstance2D
tool

# Private Members
var sdf_material: ShaderMaterial
var quad_mesh: QuadMesh

# Update Functions
func check_parent_sdf() -> void:
	var parent = get_parent()
	if parent:
		var parent_material = parent.get('sdf_material')
		if parent_material:
			sdf_material.set_shader_param('data_texture', parent_material.data_texture)
			return

	sdf_material.set_shader_param('data_texture', null)

# Overrides
func _init() -> void:
	sdf_material = ShaderMaterial.new()
	sdf_material.shader = preload('res://project/materials/shaders/sdf_2d_debug.shader')
	set_material(sdf_material)

	quad_mesh = QuadMesh.new()
	quad_mesh.size = Vector2(5, 5)
	set_mesh(quad_mesh)

func _enter_tree() -> void:
	check_parent_sdf()

func _exit_tree() -> void:
	check_parent_sdf()
