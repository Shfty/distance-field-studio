class_name GPUDataBase
extends Resource
tool

signal data_changed(index)
signal data_resized(from_size, to_size)

enum ImageFormat {
	L8 = Image.FORMAT_L8,
	LA8 = Image.FORMAT_LA8,
	R8 = Image.FORMAT_R8,
	RG8 = Image.FORMAT_RG8,
	RGB8 = Image.FORMAT_RGB8,
	RGBA8 = Image.FORMAT_RGBA8,
	RF = Image.FORMAT_RF,
	RGF = Image.FORMAT_RGF,
	RGBF = Image.FORMAT_RGBF,
	RGBAF = Image.FORMAT_RGBAF
}

enum FormatType {
	LUM = 0,
	BYTE = 1,
	FLOAT = 2
}

# Public Members
var data: Array setget set_data
var data_ptr: int

# Setters
func set_data(new_data: Array) -> void:
	if data.size() != new_data.size():
		resize_data(new_data.size())

	for i in range(0, new_data.size()):
		if not new_data[i]:
			set_data_by_index(get_data_default(), i)
		elif data[i] != new_data[i]:
			set_data_by_index(new_data[i], i)

func set_data_by_index(value, index: int) -> void:
	if index >= data.size():
		resize_data(index + 1)

	if data[index] != value:
		data[index] = value
		emit_signal('data_changed', index)

func append_data(value) -> void:
	data.append(value)
	emit_signal('data_changed', data.size() - 1)

func append_array_data(value: Array) -> void:
	var start = data.size()
	data += value
	var end = data.size()
	for i in range(start, end):
		emit_signal('data_changed', i)

func resize_data(size: int, emit_signal: bool = true) -> void:
	var prev_size := data.size()

	data.resize(size)
	for i in range(prev_size, size):
		data[i] = get_data_default()

	emit_signal('data_resized', prev_size, size)

# Getters
func get_default_resource_name() -> String:
	return 'GPUDataBase'

func get_image_format_type() -> int:
	return FormatType.LUM

func get_image_format_components() -> int:
	return 1

func get_image_size() -> Vector2:
	var data_array = get_data_array()
	if data_array:
		return Vector2(data_array.size() / get_image_format_components(), 1)
	return Vector2.ZERO

func get_data(index: int) -> Color:
	return get_data_array()[index]

func get_data_component_count(_index: int) -> int:
	return 1

func get_data_array():
	return data

func get_data_type_hint() -> String:
	return ''

func get_data_default():
	return null

# Overrides
func _init() -> void:
	if resource_name == '':
		resource_name = get_default_resource_name()

	data = []
	data_ptr = 0

func _get_property_list() -> Array:
	return [
		{
			'name': 'data',
			'type': TYPE_ARRAY,
			'hint': get_data_type_hint()
		}
	]

# Business Logic
func clear_data() -> void:
	resize_data(0)
	reset_data_ptr()

func reset_data_ptr() -> void:
	data_ptr = 0

func read_data() -> Color:
	if check_done():
		return Color.black

	var color = read_data_internal()
	data_ptr += 1
	return color

func write_data(value) -> void:
	set_data_by_index(value, data_ptr)
	data_ptr += 1

func read_data_internal() -> Color:
	return get_data_array()[data_ptr]

func check_done() -> bool:
	var data_array = get_data_array()
	if not data_array:
		return true

	return data_ptr >= data_array.size()
