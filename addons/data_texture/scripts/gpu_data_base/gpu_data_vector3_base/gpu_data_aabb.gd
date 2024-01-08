class_name GPUDataAABB
extends GPUDataVector3Base
tool

# Getters
func get_default_resource_name() -> String:
	return 'GPUDataAABB'

func get_data_array():
	if not data:
		return null

	var data_array = PoolVector3Array()
	for aabb in data:
		data_array.append(aabb.position)
		data_array.append(aabb.size)
	return data_array

func get_data_component_count(_index: int) -> int:
	return 2

func get_data_type_hint() -> String:
	return 'AABB'

func get_data_default():
	return AABB()
