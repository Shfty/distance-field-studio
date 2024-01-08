class_name GPUDataFloatBase
extends GPUDataBase
tool

# Getters
func get_default_resource_name() -> String:
	return 'GPUDataFloatBase'

func get_image_format_type() -> int:
	return FormatType.FLOAT

func get_data_type_hint() -> String:
	return 'float'

func get_data_default():
	return 0.0

# Overrides
func read_data() -> Color:
	var color = Color()
	for i in range(0, get_image_format_components()):
		if check_done():
			return color

		color[i] = data[data_ptr]
		data_ptr += 1
	return color
