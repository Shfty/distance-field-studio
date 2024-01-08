class_name GPUDataQuat
extends GPUDataColorBase
tool

# Getters
func get_default_resource_name() -> String:
	return 'GPUDataQuat'

func get_data_array():
	if not data:
		return null

	var data_array = PoolColorArray()
	for quat in data:
		data_array.append(Color(quat.x, quat.y, quat.z, quat.w))
	return data_array

func get_data_type_hint() -> String:
	return 'Quat'

func get_data_default():
	return Quat()
