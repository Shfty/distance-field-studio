class_name DataTextureUtil

static func disconnect_checked(from_object: Object, from_signal: String, to_object: Object, to_method: String) -> void:
	if from_object and from_object.is_connected(from_signal, to_object, to_method):
		from_object.disconnect(from_signal, to_object, to_method)

static func connect_checked(from_object: Object, from_signal: String, to_object: Object, to_method: String, binds: Array = []) -> void:
	if from_object and not from_object.is_connected(from_signal, to_object, to_method):
		from_object.connect(from_signal, to_object, to_method, binds)
