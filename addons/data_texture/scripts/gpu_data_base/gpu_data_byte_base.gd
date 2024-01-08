class_name GPUDataByteBase
extends GPUDataBase
tool

# Getters
func get_default_resource_name() -> String:
	return 'GPUDataByteBase'

func get_image_format_type() -> int:
	return FormatType.BYTE

func get_data_type_hint() -> String:
	return 'int'

func get_data_default():
	return 0

# Overrides
func read_data() -> Color:
	var color = Color(0, 0, 0, 1)
	for i in range(0, get_image_format_components()):
		if check_done():
			return color

		match i:
			0:
				color.r8 = data[data_ptr]
			1:
				color.g8 = data[data_ptr]
			2:
				color.b8 = data[data_ptr]
			3:
				color.a8 = data[data_ptr]

		data_ptr += 1
	return color
