class_name DistanceField
extends Resource
tool

signal generated_shader_changed()

# Public Members
var update := false setget set_update

var base_shader := preload("res://addons/distance_field_studio/shaders/sphere_trace.shader") setget set_base_shader

var shader_library: ShaderLibrary = preload("res://addons/distance_field_studio/resources/shader_library/distance_field_library.tres") setget set_library
var distance_field_function: DistanceFieldFunction = null setget set_distance_field_function
var material_function: MaterialFunction = null setget set_material_function

var generated_shader = null setget set_generated_shader
var shader_params = SphereTraceParams.new()
var uniforms := {} setget set_uniforms

# Setters
func set_update(new_update: bool) -> void:
	if update != new_update:
		generate_shader()

func set_base_shader(new_base_shader: Shader) -> void:
	if base_shader != new_base_shader:
		base_shader = new_base_shader
		generate_shader()

func set_uniforms(new_uniforms: Dictionary) -> void:
	if uniforms != new_uniforms:
		uniforms = new_uniforms
		generate_shader()

func set_library(new_shader_library: ShaderLibrary) -> void:
	if not new_shader_library:
		shader_library = null
		clear_shader()
	elif shader_library != new_shader_library:
		shader_library = new_shader_library
		generate_shader()

func set_distance_field_function(new_distance_field_function: DistanceFieldFunction) -> void:
	if not new_distance_field_function:
		distance_field_function = null
		clear_shader()
	elif distance_field_function != new_distance_field_function:
		conditional_disconnect(distance_field_function, 'signed_distance_function_changed', self, 'generate_shader')
		conditional_disconnect(distance_field_function, 'normal_function_changed', self, 'generate_shader')
		conditional_disconnect(distance_field_function, 'tangent_function_changed', self, 'generate_shader')
		conditional_disconnect(distance_field_function, 'binormal_function_changed', self, 'generate_shader')

		distance_field_function = new_distance_field_function
		if distance_field_function and not distance_field_function.is_connected('signed_distance_function_changed', self, 'generate_shader'):
			distance_field_function.connect('signed_distance_function_changed', self, 'generate_shader')

		conditional_connect(distance_field_function, 'signed_distance_function_changed', self, 'generate_shader')
		conditional_connect(distance_field_function, 'normal_function_changed', self, 'generate_shader')
		conditional_connect(distance_field_function, 'tangent_function_changed', self, 'generate_shader')
		conditional_connect(distance_field_function, 'binormal_function_changed', self, 'generate_shader')

func set_material_function(new_material_function: MaterialFunction) -> void:
	if not new_material_function:
		material_function = null
		clear_shader()
	elif material_function != new_material_function:
		conditional_disconnect(material_function, 'color_function_changed', self, 'generate_shader')
		conditional_disconnect(material_function, 'metallic_function_changed', self, 'generate_shader')
		conditional_disconnect(material_function, 'specular_function_changed', self, 'generate_shader')
		conditional_disconnect(material_function, 'roughness_function_changed', self, 'generate_shader')
		conditional_disconnect(material_function, 'emission_function_changed', self, 'generate_shader')
		conditional_disconnect(material_function, 'ao_function_changed', self, 'generate_shader')
		conditional_disconnect(material_function, 'ao_light_affect_function_changed', self, 'generate_shader')

		material_function = new_material_function

		conditional_connect(material_function, 'color_function_changed', self, 'generate_shader')
		conditional_connect(material_function, 'metallic_function_changed', self, 'generate_shader')
		conditional_connect(material_function, 'specular_function_changed', self, 'generate_shader')
		conditional_connect(material_function, 'roughness_function_changed', self, 'generate_shader')
		conditional_connect(material_function, 'emission_function_changed', self, 'generate_shader')
		conditional_connect(material_function, 'ao_function_changed', self, 'generate_shader')
		conditional_connect(material_function, 'ao_light_affect_function_changed', self, 'generate_shader')

		generate_shader()

func set_generated_shader(new_generated_shader: Shader) -> void:
	pass

# Overrides
func _get_property_list() -> Array:
	return [
		{
			'name': 'update',
			'type': TYPE_BOOL
		},
		{
			'name': 'base_shader',
			'type': TYPE_OBJECT,
			'hint': PROPERTY_HINT_RESOURCE_TYPE,
			'hint_string': 'Shader'
		},
		{
			'name': 'shader_library',
			'type': TYPE_OBJECT
		},
		{
			'name': 'distance_field_function',
			'type': TYPE_OBJECT
		},
		{
			'name': 'material_function',
			'type': TYPE_OBJECT
		},
		{
			'name': 'generated_shader',
			'type': TYPE_OBJECT,
			'hint': PROPERTY_HINT_RESOURCE_TYPE,
			'hint_string': 'Shader'
		},
		{
			'name': 'shader_params',
			'type': TYPE_OBJECT,
			'hint': PROPERTY_HINT_RESOURCE_TYPE,
			'hint_string': 'SphereTraceParams'
		},
		{
			'name': 'uniforms',
			'type': TYPE_DICTIONARY
		}
	]

# Utility
func conditional_disconnect(from_obj: Object, from_func: String, to_obj: Object, to_func: String) -> void:
	if not from_obj or not to_obj:
		return

	if from_obj.is_connected(from_func, to_obj, to_func):
		from_obj.disconnect(from_func, to_obj, to_func)

func conditional_connect(from_obj: Object, from_func: String, to_obj: Object, to_func: String) -> void:
	if not from_obj or not to_obj:
		return

	if not from_obj.is_connected(from_func, to_obj, to_func):
		from_obj.connect(from_func, to_obj, to_func)

# Business Logic
func clear_shader() -> void:
	generated_shader = null
	emit_signal("generated_shader_changed")

func generate_shader() -> void:
	var code := base_shader.code

	var uniform_code := ""
	var texture_defaults := {}

	for uniform in uniforms:
		var value = uniforms[uniform]
		uniform_code += DistanceFieldUtil.gdscript_value_to_glsl('uniform', uniform, value)
		if value is Texture:
			texture_defaults[uniform] = value

	code = code.replace("\/\/ sphere_trace:uniforms", uniform_code)

	if distance_field_function:
		code = code.replace("\/\/ sphere_trace:signed_distance_function", distance_field_function.signed_distance_function)
		code = code.replace("\/\/ sphere_trace:normal_function", distance_field_function.normal_function)
		code = code.replace("\/\/ sphere_trace:tangent_function", distance_field_function.tangent_function)
		code = code.replace("\/\/ sphere_trace:binormal_function", distance_field_function.binormal_function)

	if material_function:
		code = code.replace("\/\/ sphere_trace:color_function", material_function.color_function)
		code = code.replace("\/\/ sphere_trace:metallic_function", material_function.metallic_function)
		code = code.replace("\/\/ sphere_trace:specular_function", material_function.specular_function)
		code = code.replace("\/\/ sphere_trace:roughness_function", material_function.roughness_function)
		code = code.replace("\/\/ sphere_trace:emission_function", material_function.emission_function)
		code = code.replace("\/\/ sphere_trace:ao_function", material_function.ao_function)
		code = code.replace("\/\/ sphere_trace:ao_light_affect_function", material_function.ao_light_affect_function)

	if shader_library:
		code = code.replace("\/\/ sphere_trace:constants", shader_library.get_constant_code())
		code = code.replace("\/\/ sphere_trace:library_modify_functions", shader_library.get_modify_function_code(code))
		code = code.replace("\/\/ sphere_trace:library_signed_distance_functions", shader_library.get_signed_distance_function_code(code))
		code = code.replace("\/\/ sphere_trace:library_normal_functions", shader_library.get_normal_function_code(code))
		code = code.replace("\/\/ sphere_trace:library_color_functions", shader_library.get_color_function_code(code))

	generated_shader = Shader.new()
	generated_shader.code = code

	for uniform in texture_defaults:
		generated_shader.set_default_texture_param(uniform, texture_defaults[uniform])

	emit_signal("generated_shader_changed")

