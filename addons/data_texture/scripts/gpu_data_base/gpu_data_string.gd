class_name GPUDataString
extends GPUDataBase
tool

# Getters
func get_default_resource_name() -> String:
	return 'GPUDataString'

func get_image_format_type() -> int:
	return FormatType.BYTE

func get_image_format_components() -> int:
	return 1

func get_data_array():
	if not data:
		return null

	return PoolStringArray(data).join('\n').to_ascii()

func get_data_type_hint() -> String:
	return 'String'

func get_data_default():
	return ''

func get_data_component_count(index: int) -> int:
	return data[index].length()

# Overrides
func read_data_internal() -> Color:
	var data_array = get_data_array()
	var color := Color()
	color.r8 = get_data_array()[data_ptr]
	return color

func get_data(index: int) -> Color:
	var color := Color()
	color.r8 = get_data_array()[data_ptr]
	return color
