class_name DistanceFieldFunction
extends Resource

signal signed_distance_function_changed()
signal normal_function_changed()
signal tangent_function_changed()
signal binormal_function_changed()

export(String, MULTILINE) var signed_distance_function := "" setget set_signed_distance_function
export(String, MULTILINE) var normal_function := "" setget set_normal_function
export(String, MULTILINE) var tangent_function := "" setget set_tangent_function
export(String, MULTILINE) var binormal_function := "" setget set_binormal_function

func set_signed_distance_function(new_signed_distance_function: String) -> void:
	if signed_distance_function != new_signed_distance_function:
		signed_distance_function = new_signed_distance_function
		emit_signal('signed_distance_function_changed')

func set_normal_function(new_normal_function: String) -> void:
	if normal_function != new_normal_function:
		normal_function = new_normal_function
		emit_signal('normal_function_changed')

func set_tangent_function(new_tangent_function: String) -> void:
	if tangent_function != new_tangent_function:
		tangent_function = new_tangent_function
		emit_signal('tangent_function_changed')

func set_binormal_function(new_binormal_function: String) -> void:
	if binormal_function != new_binormal_function:
		binormal_function = new_binormal_function
		emit_signal('binormal_function_changed')
