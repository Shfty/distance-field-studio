class_name GPUDataBasis
extends GPUDataVector3Base
tool

# Getters
func get_default_resource_name() -> String:
	return 'GPUDataBasis'

func get_data_array():
	if not data:
		return null

	var data_array = PoolVector3Array()
	for basis in data:
		data_array.append(basis.x)
		data_array.append(basis.y)
		data_array.append(basis.z)
	return data_array

func get_data_component_count(_index: int) -> int:
	return 3

func get_data_type_hint() -> String:
	return 'Basis'

func get_data_default():
	return Basis()
