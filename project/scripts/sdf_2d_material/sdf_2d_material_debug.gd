class_name SDF2DMaterialDebug
extends SDF2DMaterialBase
tool

func get_sdf_shader() -> Shader:
	return preload("res://project/materials/shaders/sdf_2d_debug.shader")
