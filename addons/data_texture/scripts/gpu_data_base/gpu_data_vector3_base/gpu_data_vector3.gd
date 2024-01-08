class_name GPUDataVector3
extends GPUDataVector3Base
tool

# Getters
func get_default_resource_name() -> String:
	return 'GPUDataVector3'

func get_data_type_hint() -> String:
	return 'Vector3'

func get_data_default():
	return Vector3()
