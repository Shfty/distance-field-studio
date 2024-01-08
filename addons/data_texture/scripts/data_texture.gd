class_name DataTexture
extends ImageTexture
tool

# Constants
const PRINT := false

# Enums
enum UpdateMode {
	AUTOMATIC = 0,
	MANUAL = 1
}

enum IndexMode {
	Y_AXIS = 0,
	POINTER = 1
}

# Public Members
var update_mode: int = UpdateMode.AUTOMATIC setget set_update_mode
var force_update := false setget set_force_update
var index_mode: int = IndexMode.Y_AXIS setget set_index_mode
var gpu_data: Array setget set_gpu_data

# Private Members
var image: Image
var write_buffer := []

# Setters
func set_update_mode(new_update_mode: int) -> void:
	if PRINT:
		print('%s set update mode: %s' % [get_name(), new_update_mode])

	if update_mode != new_update_mode:
		update_mode = new_update_mode
		if update_mode == UpdateMode.AUTOMATIC:
			connect_data()
			full_update()
		else:
			disconnect_data()

func set_force_update(new_force_update: bool) -> void:
	if PRINT:
		print('%s set force update: %s' % [get_name(), new_force_update])

	if force_update != new_force_update:
		full_update()

func set_index_mode(new_index_mode: int) -> void:
	if PRINT:
		print('%s set index_mode: %s' % [get_name(), new_index_mode])
	if index_mode != new_index_mode:
		index_mode = new_index_mode
		if update_mode == UpdateMode.AUTOMATIC:
			full_update()

func set_gpu_data(new_gpu_data: Array) -> void:
	if PRINT:
		print('%s set gpu data: %s' % [get_name(), new_gpu_data])

	if gpu_data.size() != new_gpu_data.size():
		gpu_data.resize(new_gpu_data.size())

	for i in range(0, new_gpu_data.size()):
		disconnect_data_single(gpu_data[i])

		if not new_gpu_data[i] is GPUDataBase:
			gpu_data[i] = GPUDataBase.new()
		elif gpu_data[i] != new_gpu_data[i]:
			gpu_data[i] = new_gpu_data[i]


	if update_mode == UpdateMode.AUTOMATIC:
		update_image(get_image_size(), get_image_format())

		for i in range(0, gpu_data.size()):
			connect_data_single(gpu_data[i], i)

# Getters
func get_image_format_from_data(type: int, components: int) -> int:
	match type:
		GPUDataBase.FormatType.LUM:
			match components:
				1:
					return GPUDataBase.ImageFormat.L8
				2:
					return GPUDataBase.ImageFormat.LA8
			return GPUDataBase.ImageFormat.L8
		GPUDataBase.FormatType.BYTE:
			match components:
				1:
					return GPUDataBase.ImageFormat.R8
				2:
					return GPUDataBase.ImageFormat.RG8
				3:
					return GPUDataBase.ImageFormat.RGB8
				4:
					return GPUDataBase.ImageFormat.RGBA8
		GPUDataBase.FormatType.FLOAT:
			match components:
				1:
					return GPUDataBase.ImageFormat.RF
				2:
					return GPUDataBase.ImageFormat.RGF
				3:
					return GPUDataBase.ImageFormat.RGBF
				4:
					return GPUDataBase.ImageFormat.RGBAF

	return -1

func get_image_format() -> int:
	var type = -1
	var components = -1

	for i in range(0, gpu_data.size()):
		var data = gpu_data[i]
		if data:
			type = max(type, gpu_data[i].get_image_format_type())
			components = max(components, gpu_data[i].get_image_format_components())

	return get_image_format_from_data(type, components)

func get_image_size() -> Vector2:
	match index_mode:
		IndexMode.POINTER:
			return get_image_size_pointer()
		IndexMode.Y_AXIS:
			return get_image_size_y_axis()

	return Vector2.ONE

func get_image_size_pointer() -> Vector2:
	var image_size = Vector2(gpu_data.size(), 1)

	for i in range(0, gpu_data.size()):
		var data = gpu_data[i]
		if data:
			image_size.x += data.get_image_size().x

	return image_size

func get_image_size_y_axis() -> Vector2:
	var image_size = Vector2(1, gpu_data.size())

	for i in range(0, gpu_data.size()):
		var data = gpu_data[i]
		if data:
			image_size.x = max(image_size.x, data.get_image_size().x)

	return image_size

func get_default_resource_name() -> String:
	return "DataTexture"

func get_property_list_internal() -> Array:
	var update_mode_string := ''
	for key in UpdateMode:
		update_mode_string += key.capitalize()
		if key != UpdateMode.keys().back():
			update_mode_string += ','

	var index_mode_string := ''
	for key in IndexMode:
		index_mode_string += key.capitalize()
		if key != IndexMode.keys().back():
			index_mode_string += ','

	return [
		{
			'name': 'Update',
			'type': TYPE_STRING,
			'usage': PROPERTY_USAGE_CATEGORY
		},
		{
			'name': 'update_mode',
			'type': TYPE_INT,
			'hint': PROPERTY_HINT_ENUM,
			'hint_string': update_mode_string
		},
		{
			'name': 'force_update',
			'type': TYPE_BOOL
		},
		{
			'name': 'Layout',
			'type': TYPE_STRING,
			'usage': PROPERTY_USAGE_CATEGORY
		},
		{
			'name': 'index_mode',
			'type': TYPE_INT,
			'hint': PROPERTY_HINT_ENUM,
			'hint_string': index_mode_string
		},
		{
			'name': 'Data',
			'type': TYPE_STRING,
			'usage': PROPERTY_USAGE_CATEGORY
		},
		{
			'name': 'gpu_data',
			'type': TYPE_ARRAY
		},
		{
			'name': 'image',
			'type': TYPE_OBJECT,
			'hint': PROPERTY_HINT_RESOURCE_TYPE,
			'hint_string': 'Image',
			'usage': PROPERTY_USAGE_NOEDITOR
		}
	]

# Update Functions
func update_image(size: Vector2, format: int) -> void:
	if PRINT:
		print('%s update image. size: %s, format: %s' % [get_name(), size, format])

	if size.x == 0 or size.y == 0 or format == -1:
		image.create(1, 1, false, Image.FORMAT_L8)
	else:
		image.create(size.x, size.y, false, format)

	create_from_image(image, flags | Texture.FLAG_VIDEO_SURFACE)

func full_update() -> void:
	if PRINT:
		print('%s full update' % [get_name()])

	var image_format = get_image_format()
	var image_size = get_image_size()

	if not image or image.get_size() != image_size or image.get_format() != image_format:
		update_image(image_size, image_format)

	if index_mode == IndexMode.POINTER:
		populate_header()

	for i in range(0, gpu_data.size()):
		var data = gpu_data[i]
		populate_gpu_data(i)

# Overrides
func _init() -> void:
	if PRINT:
		print('%s init' % [get_name()])

	if resource_name == '':
		resource_name = get_default_resource_name()

	image = Image.new()

	LS.connect_checked(VisualServer, 'frame_pre_draw', self, 'frame_pre_draw')

func _get_property_list() -> Array:
	return get_property_list_internal()

# Business Logic
func disconnect_data() -> void:
	if PRINT:
		print('%s disconnect data' % [get_name()])

	for data in gpu_data:
		disconnect_data_single(data)

func disconnect_data_single(data: GPUDataBase) -> void:
	if PRINT:
		print('%s disconnect data single. data: %s' % [get_name(), data])

	LS.disconnect_checked(data, 'data_changed', self, 'data_changed')
	LS.disconnect_checked(data, 'data_resized', self, 'data_resized')

func connect_data() -> void:
	if PRINT:
		print('%s connect data' % [get_name()])

	for i in range(0, gpu_data.size()):
		connect_data_single(gpu_data[i], i)

func connect_data_single(data: GPUDataBase, index: int) -> void:
	if PRINT:
		print('%s connect data single. data: %s, index: %s' % [get_name(), data, index])

	LS.connect_checked(data, 'data_changed', self, 'data_changed', [index])
	LS.connect_checked(data, 'data_resized', self, 'data_resized', [index])

func write_pixel(x: int, y: int, color: Color) -> void:
	if PRINT:
		print('%s write pixel. x: %s, y: %s, color: %s' % [get_name(), x, y, color])

	write_buffer.append([x, y, color])

func frame_pre_draw() -> void:
	if write_buffer.size() > 0:
		image.lock()
		for i in range(0, write_buffer.size()):
			var write = write_buffer[i]
			if PRINT:
				print("write: %s of %s with value %s" % [i + 1, write_buffer.size(), write])
			image.set_pixel(write[0], write[1], write[2])
		write_buffer.clear()
		image.unlock()
		set_data(image)

func populate_header() -> void:
	if PRINT:
		print('%s populate header' % [get_name()])

	var pixel_ptr = 0
	for i in range(0, gpu_data.size()):
		write_pixel(i, 0, Color(gpu_data.size() + pixel_ptr, 0.0, 0.0, 1.0))
		pixel_ptr += gpu_data[i].get_image_size().x

func data_changed(data_array_idx: int, gpu_data_idx: int) -> void:
	if PRINT:
		print('%s data changed. data array index: %s, gpu data index: %s' % [get_name(), data_array_idx, gpu_data_idx])

	var image_format = get_image_format()
	var image_size = get_image_size()

	if not image or image.get_size() != image_size or image.get_format() != image_format:
		full_update()
		return

	populate_data_single(gpu_data_idx, data_array_idx)

func data_resized(from_size: int, to_size: int, gpu_data_idx: int) -> void:
	if PRINT:
		print('%s data %s resized from %s to %s' % [get_name(), gpu_data_idx, from_size, to_size])

	match index_mode:
		IndexMode.POINTER:
			full_update()
		IndexMode.Y_AXIS:
			if not image or image.get_size() != get_image_size() or image.get_format() != get_image_format():
				print('%s recreating image %s with size %s and format %s' % [get_name(), image, image.get_size(), image.get_format()])
				full_update()
			else:
				if to_size > from_size:
					for i in range(from_size, to_size):
						populate_data_single(gpu_data_idx, i)
				elif to_size < from_size:
					for i in range(to_size, from_size):
						clear_data_single(gpu_data_idx, i)


func populate_gpu_data(gpu_data_idx: int) -> void:
	if PRINT:
		print('%s populate gpu data. index: %s' % [get_name(), gpu_data_idx])

	var data = gpu_data[gpu_data_idx]

	if not data:
		return

	var pixel_ptr := 0
	if index_mode == IndexMode.POINTER:
		pixel_ptr = gpu_data.size()
		for i in range(0, gpu_data_idx):
			pixel_ptr += gpu_data[i].get_image_size().x

	var image_size = get_image_size()
	data.reset_data_ptr()
	while not data.check_done():
		var x = pixel_ptr % int(image_size.x)
		var y := 0

		match index_mode:
			IndexMode.POINTER:
				y = pixel_ptr / image_size.x
			IndexMode.Y_AXIS:
				y = gpu_data_idx

		write_pixel(x, y, data.read_data())
		pixel_ptr += 1

func populate_data_single(gpu_data_idx: int, data_array_idx: int) -> void:
	if PRINT:
		print('%s populate data single. gpu data idx: %s, data array idx: %s' % [get_name(), gpu_data_idx, data_array_idx])

	var data = gpu_data[gpu_data_idx]

	if not data:
		return

	var component_count = data.get_data_component_count(data_array_idx)

	var pixel_ptr := 0
	if index_mode == IndexMode.POINTER:
		pixel_ptr = gpu_data.size()

	var image_size = get_image_size()
	for i in range(0, gpu_data_idx):
		match index_mode:
			IndexMode.POINTER:
				pixel_ptr += gpu_data[i].get_image_size().x
			IndexMode.Y_AXIS:
				pixel_ptr += image_size.x

	pixel_ptr += data_array_idx * component_count

	for i in range(0, component_count):
		var idx = pixel_ptr + i
		var x = idx % int(image_size.x)
		var y = idx / image_size.x
		write_pixel(x, y, data.get_data(data_array_idx * component_count + i))

func clear_data_single(gpu_data_idx: int, data_array_idx: int) -> void:
	if PRINT:
		print('%s clear data single. gpu data idx: %s, data array idx: %s' % [get_name(), gpu_data_idx, data_array_idx])

	var data = gpu_data[gpu_data_idx]

	if not data:
		return

	var component_count = data.get_data_component_count(data_array_idx)

	var pixel_ptr := 0
	if index_mode == IndexMode.POINTER:
		pixel_ptr = gpu_data.size()

	var image_size = get_image_size()
	for i in range(0, gpu_data_idx):
		match index_mode:
			IndexMode.POINTER:
				pixel_ptr += gpu_data[i].get_image_size().x
			IndexMode.Y_AXIS:
				pixel_ptr += image_size.x

	pixel_ptr += data_array_idx * component_count

	for i in range(0, component_count):
		var idx = pixel_ptr + i
		var x = idx % int(image_size.x)
		var y = idx / image_size.x
		write_pixel(x, y, Color(0, 0, 0, 0))
