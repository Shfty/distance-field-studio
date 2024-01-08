class_name GPUDataColorBase
extends GPUDataBase
tool

# Getters
func get_default_resource_name() -> String:
	return 'GPUDataColorBase'

func get_image_format_type() -> int:
	return FormatType.FLOAT

func get_image_format_components() -> int:
	return 4

func get_image_size() -> Vector2:
	var data_array = get_data_array()
	if data_array:
		return Vector2(data_array.size(), 1)
	return Vector2.ZERO
