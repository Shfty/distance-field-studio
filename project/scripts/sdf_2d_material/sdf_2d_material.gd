class_name SDF2DMaterial
extends SDF2DMaterialBase
tool

func get_sdf_shader() -> Shader:
	return preload("res://project/materials/shaders/sdf_2d.shader")
