class_name GPUDataColor
extends GPUDataColorBase
tool

# Getters
func get_default_resource_name() -> String:
	return 'GPUDataColor'

func get_data_type_hint() -> String:
	return 'Color'

func get_data_default():
	return Color()
