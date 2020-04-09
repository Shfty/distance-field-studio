extends ViewportContainer
tool

func _init() -> void:
	if not is_connected('resized', self, 'resized'):
		connect('resized', self, 'resized')

func resized() -> void:
	$Viewport.set_size(rect_size)
