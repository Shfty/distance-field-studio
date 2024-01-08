class_name CapturePass
extends Resource

export(Material) var mesh_material: Material
export(Material) var overlay_material: Material

func _init():
	if resource_name == "":
		resource_name = "capture_pass"
