class_name GLSLFunction
extends Resource
tool

export(String) var name
export(String) var return_type
export(Array) var params setget set_params
export(String, MULTILINE) var implementation

func set_params(new_params: Array) -> void:
	if params != new_params:
		params = new_params

	for i in range(0, params.size()):
		if not params[i] is GLSLParameter:
			params[i] = GLSLParameter.new()

func get_code() -> String:
	var param_string := ""
	for param in params:
		param_string += param.get_code()
		if param != params.back():
			param_string += ", "
	return "%s %s(%s) {\n\t%s\n}" % [
		return_type,
		name,
		param_string,
		implementation.replace("\n", "\n\t")
	]
