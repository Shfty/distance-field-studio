class_name ShaderLibrary
extends Resource
tool

export(Dictionary) var constants := {}
export(Array, Resource) var modify_functions := [] setget set_modify_functions
export(Array, Resource) var signed_distance_functions_3d := [] setget set_signed_distance_functions_3d
export(Array, Resource) var signed_distance_functions_2d := [] setget set_signed_distance_functions_2d
export(Array, Resource) var normal_functions := [] setget set_normal_functions
export(Array, Resource) var color_functions := [] setget set_color_functions

func set_modify_functions(new_modify_functions: Array) -> void:
	if modify_functions != new_modify_functions:
		modify_functions = new_modify_functions

	for i in range(0, modify_functions.size()):
		if not modify_functions[i] or not modify_functions[i] is GLSLFunction:
			modify_functions[i] = Object()

func set_signed_distance_functions_3d(new_signed_distance_functions_3d: Array) -> void:
	if signed_distance_functions_3d != new_signed_distance_functions_3d:
		signed_distance_functions_3d = new_signed_distance_functions_3d

	for i in range(0, signed_distance_functions_3d.size()):
		if not signed_distance_functions_3d[i] or not signed_distance_functions_3d[i] is GLSLFunction:
			signed_distance_functions_3d[i] = Object()

func set_signed_distance_functions_2d(new_signed_distance_functions_2d: Array) -> void:
	if signed_distance_functions_2d != new_signed_distance_functions_2d:
		signed_distance_functions_2d = new_signed_distance_functions_2d

	for i in range(0, signed_distance_functions_2d.size()):
		if not signed_distance_functions_2d[i] or not signed_distance_functions_2d[i] is GLSLFunction:
			signed_distance_functions_2d[i] = Object()

func set_normal_functions(new_normal_functions: Array) -> void:
	if normal_functions != new_normal_functions:
		normal_functions = new_normal_functions

	for i in range(0, normal_functions.size()):
		if not normal_functions[i] or not normal_functions[i] is GLSLFunction:
			normal_functions[i] = Object()

func set_color_functions(new_color_functions: Array) -> void:
	if color_functions != new_color_functions:
		color_functions = new_color_functions

	for i in range(0, color_functions.size()):
		if not color_functions[i] or not color_functions[i] is GLSLFunction:
			color_functions[i] = Object()

func get_constant_code() -> String:
	var code := ""

	for constant in constants:
		code += DistanceFieldUtil.gdscript_value_to_glsl('const', constant, constants[constant])

	return code

func get_modify_function_code(ref_code: String) -> String:
	var code := ""

	for function in modify_functions:
		if ref_code.find(function.name) != -1:
			code += function.get_code()

	return code

func get_signed_distance_function_code(ref_code: String) -> String:
	var code := ""

	for function in signed_distance_functions_3d:
		if ref_code.find(function.name) != -1:
			code += function.get_code()

	for function in signed_distance_functions_2d:
		if ref_code.find(function.name) != -1:
			code += function.get_code()

	return code

func get_normal_function_code(ref_code: String) -> String:
	var code := ""

	for function in normal_functions:
		if ref_code.find(function.name) != -1:
			code += function.get_code()

	return code

func get_color_function_code(ref_code: String) -> String:
	var code := ""

	for function in color_functions:
		if ref_code.find(function.name) != -1:
			code += function.get_code()

	return code
