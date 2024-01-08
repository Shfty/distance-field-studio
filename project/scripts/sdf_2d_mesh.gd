class_name SDF2DMesh
extends ArrayMesh

var sdf_program setget set_sdf_program
export(Vector2) var bounds_padding := Vector2.ZERO setget set_bounds_padding

var bounding_box_interpreter: BoundingBoxInterpreter

func set_sdf_program(new_sdf_program: Resource) -> void:
	if sdf_program != new_sdf_program:
		if sdf_program:
			if sdf_program.is_connected('commands_changed', self, 'sdf_program_commands_changed'):
				sdf_program.disconnect('commands_changed', self, 'sdf_program_commands_changed')

		sdf_program = new_sdf_program

		if sdf_program:
			if not sdf_program.is_connected('commands_changed', self, 'sdf_program_commands_changed'):
				sdf_program.connect('commands_changed', self, 'sdf_program_commands_changed')

		bounding_box_interpreter.before_sdf_program_change()
		bounding_box_interpreter.sdf_program = sdf_program
		bounding_box_interpreter.after_sdf_program_change()

func sdf_program_commands_changed() -> void:
	bounding_box_interpreter.before_sdf_program_change()
	bounding_box_interpreter.interpret()
	bounding_box_interpreter.after_sdf_program_change()

func set_bounds_padding(new_bounds_padding: Vector2) -> void:
	if bounds_padding != new_bounds_padding:
		bounds_padding = new_bounds_padding
		bounding_box_interpreter.interpret()
		update_mesh()

func _init() -> void:
	if resource_name == '':
		resource_name = 'SDF2DMesh'

	bounding_box_interpreter = BoundingBoxInterpreter.new()
	bounding_box_interpreter.connect('rect_changed', self, 'update_mesh')

func update_mesh() -> void:
	# print("%s update mesh" % [get_name()])
	for i in range(0, get_surface_count()):
		surface_remove(0);

	if not sdf_program:
		return

	var rect = bounding_box_interpreter.rect
	rect = rect.grow_individual(bounds_padding.x, bounds_padding.y, bounds_padding.x, bounds_padding.y)

	var position3 = Vector3(rect.position.x, rect.position.y, 0.0)

	var verts := PoolVector3Array([
		position3 + Vector3.RIGHT * rect.size.x,
		position3,
		position3 + Vector3(rect.size.x, rect.size.y, 0.0),
		position3 + Vector3.UP * rect.size.y
	])

	var normals := PoolVector3Array([
		Vector3.BACK,
		Vector3.BACK,
		Vector3.BACK,
		Vector3.BACK
	])

	var tangents := PoolRealArray([
		1.0, 0.0, 0.0, 1.0,
		1.0, 0.0, 0.0, 1.0,
		1.0, 0.0, 0.0, 1.0,
		1.0, 0.0, 0.0, 1.0,
	])

	var colors := PoolColorArray([
		Color.white,
		Color.white,
		Color.white,
		Color.white
	])

	var uvs := PoolVector2Array([
		Vector3.ONE,
		Vector3.UP,
		Vector2.RIGHT,
		Vector2.ZERO,
	])

	add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, [
		verts,
		normals,
		tangents,
		colors,
		uvs,
		null,
		null,
		null,
		null
	])

	#print("updating quad mesh with vertices: %s" % [verts])
