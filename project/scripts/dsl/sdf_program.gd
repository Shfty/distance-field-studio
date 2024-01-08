class_name DistanceFieldProgram
extends Resource
tool

signal commands_changed()
signal uniforms_changed()

export(Array) var commands setget set_commands

func set_commands(new_commands: Array) -> void:
	for i in range(0, new_commands.size()):
		if not new_commands[i] as DistanceFieldDSL.Command:
			return

	if commands != new_commands:
		commands = new_commands

func _init() -> void:
	if resource_name == '':
		resource_name = "SDFProgram"

func clear_commands() -> void:
	commands.clear()

func commit_commands() -> void:
	# print("%s commit commands" % [get_name()])
	emit_signal('commands_changed')
