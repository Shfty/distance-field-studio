class_name GPUDataTransform2D
extends GPUDataVector2Base
tool

# Getters
func get_default_resource_name() -> String:
	return 'GPUDataTransform2D'

func get_data_array():
	if not data:
		return null

	var data_array = PoolVector2Array()
	for transform2d in data:
		data_array.append(transform2d.x)
		data_array.append(transform2d.y)
		data_array.append(transform2d.origin)
	return data_array

func get_data_component_count(index: int) -> int:
	return 3

func get_data_type_hint() -> String:
	return 'Transform2D'

func get_data_default():
	return Transform2D()
