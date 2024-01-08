class_name GPUDataRect2
extends GPUDataVector2Base
tool

# Getters
func get_default_resource_name() -> String:
	return 'GPUDataRect2'

func get_data_array():
	if not data:
		return null

	var data_array = PoolVector2Array()
	for rect in data:
		data_array.append(rect.position)
		data_array.append(rect.size)
	return data_array

func get_data_component_count(index: int) -> int:
	return 2

func get_data_type_hint() -> String:
	return 'Rect2'

func get_data_default():
	return Rect2()
