class_name GPUDataIntBase
extends GPUDataBase
tool

# Getters
func get_default_resource_name() -> String:
	return 'GPUDataIntBase'

func get_image_format_type() -> int:
	return FormatType.FLOAT

func get_data_type_hint() -> String:
	return 'int'

func get_data_default():
	return 0

# Overrides
func read_data() -> Color:
	var color = Color(0.0, 0.0, 0.0, 1.0)
	for i in range(0, get_image_format_components()):
		if check_done():
			return color

		color[i] = data[data_ptr]
		data_ptr += 1
	return color
