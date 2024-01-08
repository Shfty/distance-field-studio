class_name GPUDataBool
extends GPUDataBase
tool

# Getters
func get_default_resource_name() -> String:
	return 'GPUDataBool'

func get_image_format_type() -> int:
	return FormatType.BYTE

func get_image_format_components() -> int:
	return 1

func get_data_type_hint() -> String:
	return 'bool'

func get_data_default():
	return false

# Overrides
func read_data() -> Color:
	var color = Color()
	if check_done():
		return color
	color.r8 = 255 if data[data_ptr] else 0
	data_ptr += 1
	return color

func read_data_internal() -> Color:
	var data_array = get_data_array()
	var color := Color()
	color.r8 = 255 if data[data_ptr] else 0
	return color
