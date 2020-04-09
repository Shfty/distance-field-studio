extends Node
tool

export(bool) var update setget set_update
export(String, DIR) var target_directory
export(Array) var capture_passes := [] setget set_capture_passes
export(int) var current_pass_idx := 0 setget set_current_pass_idx

func set_update(new_update: bool) -> void:
	if update != new_update:
		save_capture()

func set_current_pass_idx(new_current_pass_idx: int) -> void:
	if current_pass_idx != new_current_pass_idx:
		current_pass_idx = new_current_pass_idx
		capture_pass()

func set_capture_passes(new_capture_passes: Array) -> void:
	if capture_passes != new_capture_passes:
		capture_passes = new_capture_passes

		for i in range(0, capture_passes.size()):
			if not capture_passes[i] is CapturePass:
				capture_passes[i] = CapturePass.new()

func capture_pass() -> void:
	var capture_pass = capture_passes[current_pass_idx]
	$World/MeshInstance.material_override = capture_pass.mesh_material
	$World/DepthOverlay.material_override = capture_pass.overlay_material
	$World/DepthOverlay.visible = capture_pass.overlay_material != null

	for viewport in $World/Viewports.get_children():
		viewport.update_worlds()

	for viewport in $UI/CenterContainer/GridContainer.get_children():
		viewport.update()
	$UI/CenterContainer/GridContainer.update()

func save_capture() -> void:
	var capture_pass = capture_passes[current_pass_idx]
	var capture_dir = target_directory + "/" + capture_pass.get_name() + "/"
	for viewport in $World/Viewports.get_children():
		var viewport_texture = viewport.get_texture()
		var viewport_image = viewport_texture.get_data()
		var image_texture = ImageTexture.new()
		image_texture.create_from_image(viewport_image)

		var dir = Directory.new()
		dir.make_dir_recursive(capture_dir)

		var capture_file = viewport.get_name() + ".tres"
		var capture_path = capture_dir + capture_file

		ResourceSaver.save(capture_path, image_texture)
		image_texture.take_over_path(capture_path)
