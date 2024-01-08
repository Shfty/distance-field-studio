class_name GPUDataPlane
extends GPUDataColorBase
tool

# Getters
func get_default_resource_name() -> String:
	return 'GPUDataPlane'

func get_data_array():
	if not data:
		return null

	var data_array = PoolColorArray()
	for plane in data:
		data_array.append(Color(plane.x, plane.y, plane.z, plane.d))
	return data_array

func get_data_type_hint() -> String:
	return 'Plane'

func get_data_default():
	return Plane()
