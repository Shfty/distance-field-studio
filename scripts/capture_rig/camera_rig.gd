extends Spatial
tool

var cameras := []

var offsets := [
	Vector3.UP,
	Vector3.DOWN,
	Vector3.RIGHT,
	Vector3.LEFT,
	Vector3.BACK,
	Vector3.FORWARD
]

func _init() -> void:
	for i in range(0, offsets.size()):
		var camera = Camera.new()
		camera.transform.origin = offsets[i]
		var facing = -camera.transform.origin
		camera.transform.basis = Transform.IDENTITY.looking_at(facing, Vector3.UP).basis
		add_child(camera)

		var edited_scene_root = get_tree().get_edited_scene_root()
		if edited_scene_root:
			camera.set_owner(edited_scene_root)

		cameras.append(camera)

func _enter_tree() -> void:
	for i in range(0, offsets.size()):
		var camera = Camera.new()
		camera.transform.origin = offsets[i]
		var facing = -camera.transform.origin
		camera.transform.basis = Transform.IDENTITY.looking_at(facing, Vector3.UP).basis
		add_child(camera)

		var edited_scene_root = get_tree().get_edited_scene_root()
		if edited_scene_root:
			camera.set_owner(edited_scene_root)

		cameras.append(camera)

func _exit_tree() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
