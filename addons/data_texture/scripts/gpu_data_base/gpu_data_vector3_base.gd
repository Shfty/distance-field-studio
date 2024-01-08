class_name GPUDataVector3Base
extends GPUDataBase
tool

# Getters
func get_default_resource_name() -> String:
	return 'GPUDataVector3Base'

func get_image_format_type() -> int:
	return FormatType.FLOAT

func get_image_format_components() -> int:
	return 3

func get_image_size() -> Vector2:
	var data_array = get_data_array()
	if data_array:
		return Vector2(data_array.size(), 1)
	return Vector2.ZERO

# Overrides
func read_data_internal() -> Color:
	var data_array = get_data_array()
	return Color(data_array[data_ptr].x, data_array[data_ptr].y, data_array[data_ptr].z, 1.0)

func get_data(index: int) -> Color:
	var data = get_data_array()[index]
	return Color(data.x, data.y, data.z, 1.0)
