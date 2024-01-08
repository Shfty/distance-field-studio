class_name SDF2DMaterialBase
extends ShaderMaterial
tool

const PRINT := false

var sdf_program setget set_sdf_program

var data_texture: DataTexture
var texture_interpreter: TextureInterpreter

func set_sdf_program(new_sdf_program: Resource) -> void:
	if sdf_program != new_sdf_program:
		if PRINT:
			print("%s set sdf program: %s" % [get_name(), new_sdf_program.commands if new_sdf_program else null])

		if sdf_program:
			if sdf_program.is_connected('commands_changed', self, 'sdf_program_commands_changed'):
				sdf_program.disconnect('commands_changed', self, 'sdf_program_commands_changed')

		sdf_program = new_sdf_program

		if sdf_program:
			if not sdf_program.is_connected('commands_changed', self, 'sdf_program_commands_changed'):
				sdf_program.connect('commands_changed', self, 'sdf_program_commands_changed')

		texture_interpreter.before_sdf_program_change()
		texture_interpreter.sdf_program = sdf_program
		texture_interpreter.after_sdf_program_change()
		sdf_program_commands_changed()

func sdf_program_commands_changed() -> void:
	texture_interpreter.interpret()

func get_sdf_shader() -> Shader:
	return preload("res://project/materials/shaders/sdf_2d.shader")

func _init() -> void:
	if resource_name == '':
		resource_name = 'SDFMaterial'

	set_shader(get_sdf_shader())

	data_texture = DataTexture.new()
	data_texture.update_mode = DataTexture.UpdateMode.MANUAL
	data_texture.index_mode = DataTexture.IndexMode.POINTER
	set_shader_param('data_texture', data_texture)

	texture_interpreter = TextureInterpreter.new()
	texture_interpreter.data_texture = data_texture
