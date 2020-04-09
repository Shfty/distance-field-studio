class_name GLSLParameter
extends Resource
tool

export(String) var name
export(String) var type

func _init() -> void:
	if resource_name == "":
		resource_name = "GLSL Parameter"

func get_code() -> String:
	return "%s %s" % [type, name]
