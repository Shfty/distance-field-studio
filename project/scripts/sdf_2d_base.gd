class_name SDF2DBase
extends Node2D
tool

# Constants
const PRINT := false

# Public Members
export(Resource) var sdf_program setget set_sdf_program

# Private Members
var ready := false

var cached_local_transform := Transform2D()
var cached_parent: Node = null

var push_transform_command: DistanceFieldDSL.PushTransformCommand
var pop_transform_command: DistanceFieldDSL.PopTransformCommand

# Setters
func set_sdf_program(new_sdf_program: Resource) -> void:
	if get_sdf_node_parent():
		new_sdf_program = null
	elif not new_sdf_program:
		new_sdf_program = DistanceFieldProgram.new()

	if sdf_program != new_sdf_program:
		sdf_program = new_sdf_program

# Change Functions
func transform_changed() -> void:
	push_transform_command.transform = transform

# Overrides
func _init() -> void:
	set_notify_transform(true)
	cached_local_transform = transform

	push_transform_command = DistanceFieldDSL.PushTransformCommand.new()
	push_transform_command.transform = transform

	pop_transform_command = DistanceFieldDSL.PopTransformCommand.new()

func _enter_tree() -> void:
	if PRINT:
		print('%s enter tree' % [get_name()])

	var parent = get_parent()

	if sdf_program:
		set_sdf_program(sdf_program.duplicate())
	else:
		set_sdf_program(null)

	if parent:
		if parent as SDF2DBase:
			cached_parent = parent

			if cached_parent.ready:
				cached_parent.update_sdf()
		elif 'sdf_program' in parent:
			parent.sdf_program = sdf_program
			if get_child_count() == 0:
				if ready:
					update_sdf()

	transform_changed()

func _exit_tree() -> void:
	if cached_parent:
		cached_parent.update_sdf()
		cached_parent = null

func _ready() -> void:
	ready = true
	update_sdf()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
			if cached_local_transform != transform:
				transform_changed()
			cached_local_transform = transform

# Business logic
func get_sdf_node_parent() -> SDF2DBase:
	return get_parent() as SDF2DBase

func update_sdf() -> void:
	var sdf_node_parent = get_sdf_node_parent()
	if not sdf_node_parent:
		if PRINT:
			print("%s update sdf" % [get_name()])
		sdf_program.clear_commands()
		build_commands(sdf_program)
		sdf_program.commit_commands()

func build_commands(sdf_program: DistanceFieldProgram) -> void:
	build_before_commands(sdf_program)

	for child in get_children():
		if child as SDF2DBase:
			child.build_commands(sdf_program)

	build_after_commands(sdf_program)

func build_before_commands(sdf_program: DistanceFieldProgram) -> void:
	pass

func build_after_commands(sdf_program: DistanceFieldProgram) -> void:
	pass
