class_name ShaderLibrary
extends Resource
tool

enum FunctionCategories {
	SDF_3D,
	SDF_2D,
	CSG,
	MODIFIER_DISTANCE,
	MODIFIER_POSITION,
	NORMAL,
	COLOR
}

export(Dictionary) var constants := {}

export(Dictionary) var function_category_names := {
	FunctionCategories.SDF_3D: '3D Signed Distance Function',
	FunctionCategories.SDF_2D: '2D Signed Distance Function',
	FunctionCategories.CSG: 'CSG',
	FunctionCategories.MODIFIER_DISTANCE: 'Distance Modifier',
	FunctionCategories.MODIFIER_POSITION: 'Position Modifier',
	FunctionCategories.NORMAL: 'Normal Function',
	FunctionCategories.COLOR: 'Color Function'
}

export(Dictionary) var functions := {
	FunctionCategories.SDF_3D: [],
	FunctionCategories.SDF_2D: [],
	FunctionCategories.CSG: [],
	FunctionCategories.MODIFIER_DISTANCE: [],
	FunctionCategories.MODIFIER_POSITION: [],
	FunctionCategories.NORMAL: [],
	FunctionCategories.COLOR: []
} setget set_functions

func set_functions(new_functions: Dictionary) -> void:
	if functions != new_functions:
		functions = new_functions
		for category in new_functions:
			var array = new_functions[category]
			for i in range(0, array.size()):
				if not array[i]:
					array[i] = Object()

func get_constant_code() -> String:
	var code := ""

	for constant in constants:
		code += DistanceFieldUtil.gdscript_value_to_glsl('const', constant, constants[constant])

	return code

func get_modify_function_code(ref_code: String) -> String:
	var code := ""

	for function in functions[FunctionCategories.CSG] + functions[FunctionCategories.MODIFIER_DISTANCE] + functions[FunctionCategories.MODIFIER_POSITION]:
		if ref_code.find(function.name) != -1:
			code += function.get_code()

	return code

func get_signed_distance_function_code(ref_code: String) -> String:
	var code := ""

	for function in functions[FunctionCategories.SDF_3D]:
		if ref_code.find(function.name) != -1:
			code += function.get_code()

	for function in functions[FunctionCategories.SDF_2D]:
		if ref_code.find(function.name) != -1:
			code += function.get_code()

	return code

func get_normal_function_code(ref_code: String) -> String:
	var code := ""

	for function in functions[FunctionCategories.NORMAL]:
		if ref_code.find(function.name) != -1:
			code += function.get_code()

	return code

func get_color_function_code(ref_code: String) -> String:
	var code := ""

	for function in functions[FunctionCategories.COLOR]:
		if ref_code.find(function.name) != -1:
			code += function.get_code()

	return code
