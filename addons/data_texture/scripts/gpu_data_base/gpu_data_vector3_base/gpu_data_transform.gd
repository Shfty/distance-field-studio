class_name GPUDataTransform
extends GPUDataVector3Base
tool

# Getters
func get_default_resource_name() -> String:
	return 'GPUDataTransform'

func get_data_array():
	if not data:
		return null

	var data_array = PoolVector3Array()
	for transform in data:
		data_array.append(transform.basis.x)
		data_array.append(transform.basis.y)
		data_array.append(transform.basis.z)
		data_array.append(transform.origin)
	return data_array

func get_data_component_count(index: int) -> int:
	return 4

func get_data_type_hint() -> String:
	return 'Transform'

func get_data_default():
	return Transform()
