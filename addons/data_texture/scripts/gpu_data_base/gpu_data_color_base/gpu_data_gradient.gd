class_name GPUDataGradient
extends GPUDataColorBase
tool

# Getters
func get_default_resource_name() -> String:
	return 'GPUDataGradient'

func get_data_array():
	if not data:
		return null

	var data_array = PoolColorArray([Color(data.size(), 0.0, 0.0, 1.0)])

	# Prefill pointers
	for gradient in data:
		data_array.append(Color.black)

	# Write data
	for g in range(0, data.size()):
		data_array[g + 1] = Color(data_array.size(), 0.0, 0.0, 1.0)
		var gradient = data[g]
		if gradient:
			var stop_count = gradient.offsets.size()
			data_array.append(Color(stop_count, 0.0, 0.0, 1.0))
			for s in range(0, stop_count):
				data_array.append(Color(gradient.offsets[s], 0.0, 0.0, 1.0))
				data_array.append(gradient.colors[s])

	return data_array

func get_data_component_count(index: int) -> int:
	return data[index].offsets.size() * 2

func get_data_type_hint() -> String:
	return 'Gradient'

func get_data_default():
	return Gradient.new()
