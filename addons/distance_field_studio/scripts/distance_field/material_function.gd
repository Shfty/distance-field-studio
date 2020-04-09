class_name MaterialFunction
extends Resource

signal color_function_changed()
signal metallic_function_changed()
signal specular_function_changed()
signal roughness_function_changed()
signal emission_function_changed()
signal ao_function_changed()
signal ao_light_affect_function_changed()

export(String, MULTILINE) var color_function := "" setget set_color_function
export(String, MULTILINE) var metallic_function := "" setget set_metallic_function
export(String, MULTILINE) var specular_function := "" setget set_specular_function
export(String, MULTILINE) var roughness_function := "" setget set_roughness_function
export(String, MULTILINE) var emission_function := "" setget set_emission_function
export(String, MULTILINE) var ao_function := "" setget set_ao_function
export(String, MULTILINE) var ao_light_affect_function := "" setget set_ao_light_affect_function

func set_color_function(new_color_function: String) -> void:
	if color_function != new_color_function:
		color_function = new_color_function
		emit_signal('color_function_changed')

func set_metallic_function(new_metallic_function: String) -> void:
	if metallic_function != new_metallic_function:
		metallic_function = new_metallic_function
		emit_signal('metallic_function_changed')

func set_specular_function(new_specular_function: String) -> void:
	if specular_function != new_specular_function:
		specular_function = new_specular_function
		emit_signal('specular_function_changed')

func set_roughness_function(new_roughness_function: String) -> void:
	if roughness_function != new_roughness_function:
		roughness_function = new_roughness_function
		emit_signal('roughness_function_changed')

func set_emission_function(new_emission_function: String) -> void:
	if emission_function != new_emission_function:
		emission_function = new_emission_function
		emit_signal('emission_function_changed')

func set_ao_function(new_ao_function: String) -> void:
	if ao_function != new_ao_function:
		ao_function = new_ao_function
		emit_signal('ao_function_changed')

func set_ao_light_affect_function(new_ao_light_affect_function: String) -> void:
	if ao_light_affect_function != new_ao_light_affect_function:
		ao_light_affect_function = new_ao_light_affect_function
		emit_signal('ao_light_affect_function_changed')
