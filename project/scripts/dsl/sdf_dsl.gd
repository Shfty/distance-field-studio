class_name DistanceFieldDSL

enum CommandType {
	SHAPE = 0,
	PUSH_TRANSFORM = 1,
	POP_TRANSFORM = 2,
	PUSH_CSG = 3,
	POP_CSG = 4,
	PUSH_DISTANCE_MODIFIER = 5,
	POP_DISTANCE_MODIFIER = 6,
	PUSH_POSITION_MODIFIER = 7,
	POP_POSITION_MODIFIER = 8
}

#
# Base DSL Types
#
class Command extends Resource:
	func _init():
		if resource_name == "":
			resource_name = get_default_resource_name()

	func get_default_resource_name() -> String:
		return "Command"

	func get_command_type() -> int:
		return -1

#
# Tree Structure
#

class SingleCommand extends Command:
	func get_default_resource_name() -> String:
		return "Single Command"

class PushCommand extends Command:
	func get_default_resource_name() -> String:
		return "Push Command"

class PopCommand extends Command:
	func get_default_resource_name() -> String:
		return "Pop Command"

#
# Distance Field Types
#

class ShapeCommand extends SingleCommand:
	enum Type {
		CIRCLE = 0,
		TRIANGLE = 1,
		SQUARE = 2,
		PENTAGON = 3,
		HEXAGON = 4,
		OCTAGON = 5
	}

	signal type_changed(type)
	signal size_changed(size)
	signal color_changed(color)
	signal gradient_changed(gradient)
	signal modulate_dist_changed(modulate_dist)

	export(Type) var type: int setget set_type
	export(Vector2) var size: Vector2 setget set_size
	export(Color) var color: Color setget set_color
	export(Gradient) var gradient: Gradient setget set_gradient
	export(float) var modulate_dist: float setget set_modulate_dist

	func set_type(new_type: int) -> void:
		if type != new_type:
			type = new_type
			emit_signal('type_changed', type)

	func set_size(new_size: Vector2) -> void:
		if size != new_size:
			size = new_size
			emit_signal('size_changed', size)

	func set_color(new_color: Color) -> void:
		if color != new_color:
			color = new_color
			emit_signal('color_changed', color)

	func set_gradient(new_gradient: Gradient) -> void:
		if gradient != new_gradient:
			gradient = new_gradient
			emit_signal('gradient_changed', gradient)

	func set_modulate_dist(new_modulate_dist: float) -> void:
		if modulate_dist != new_modulate_dist:
			modulate_dist = new_modulate_dist
			emit_signal('modulate_dist_changed', modulate_dist)

	func get_default_resource_name() -> String:
		return "Shape"

	func get_command_type() -> int:
		return CommandType.SHAPE

class PushTransformCommand extends PushCommand:
	signal transform_changed(transform)

	export(Transform2D) var transform: Transform2D setget set_transform

	func set_transform(new_transform: Transform2D) -> void:
		if transform != new_transform:
			transform = new_transform
			emit_signal('transform_changed', transform)

	func get_default_resource_name() -> String:
		return "Push Transform"

	func get_command_type() -> int:
		return CommandType.PUSH_TRANSFORM

class PopTransformCommand extends PushCommand:
	func get_default_resource_name() -> String:
		return "Pop Transform"

	func get_command_type() -> int:
		return CommandType.POP_TRANSFORM

class PushCSGCommand extends PushCommand:
	enum Type {
		UNION = 0,
		SUBTRACTION = 1,
		INTERSECTION = 2
	}

	signal type_changed(type)
	signal distance_smooth_factor_changed(distance_smooth_factor)
	signal color_smooth_factor_changed(color_smooth_factor)

	export(Type) var type: int setget set_type
	export(float) var distance_smooth_factor: float setget set_distance_smooth_factor
	export(float) var color_smooth_factor: float setget set_color_smooth_factor

	func set_type(new_type: int) -> void:
		if type != new_type:
			type = new_type
			emit_signal('type_changed', type)

	func set_distance_smooth_factor(new_distance_smooth_factor: float) -> void:
		if distance_smooth_factor != new_distance_smooth_factor:
			distance_smooth_factor = new_distance_smooth_factor
			emit_signal('distance_smooth_factor_changed', distance_smooth_factor)

	func set_color_smooth_factor(new_color_smooth_factor: float) -> void:
		if color_smooth_factor != new_color_smooth_factor:
			color_smooth_factor = new_color_smooth_factor
			emit_signal('color_smooth_factor_changed', color_smooth_factor)

	func get_default_resource_name() -> String:
		return "Push CSG"

	func get_command_type() -> int:
		return CommandType.PUSH_CSG

class PopCSGCommand extends PopCommand:
	func get_default_resource_name() -> String:
		return "Pop CSG"

	func get_command_type() -> int:
		return CommandType.POP_CSG

class PushDistanceModifierCommand extends PushCommand:
	enum Type {
		ROUND = 0,
		ANNULATE = 1,
		ELONGATE = 2
	}

	signal type_changed(type)
	signal params_changed(params)

	export(Type) var type: int setget set_type
	export(Vector2) var params: Vector2 setget set_params

	func set_type(new_type: int) -> void:
		if type != new_type:
			type = new_type
			emit_signal('type_changed', type)

	func set_params(new_params: Vector2) -> void:
		if params != new_params:
			params = new_params
			emit_signal('params_changed', params)

	func get_default_resource_name() -> String:
		return "Push Distance Modifier"

	func get_command_type() -> int:
		return CommandType.PUSH_DISTANCE_MODIFIER

class PopDistanceModifierCommand extends PopCommand:
	func get_default_resource_name() -> String:
		return "Pop Distance Modifier"

	func get_command_type() -> int:
		return CommandType.POP_DISTANCE_MODIFIER

class PushPositionModifierCommand extends PushCommand:
	enum Type {
		ELONGATE = 0,
		REFLECT = 1,
		REPEAT = 2,
		REPEAT_LIMITED = 3,
		TWIST = 4,
		BEND = 5
	}

	signal type_changed(type)
	signal params_changed(params)

	export(Type) var type: int setget set_type
	export(Vector3) var params: Vector3 setget set_params

	func set_type(new_type: int) -> void:
		if type != new_type:
			type = new_type
			emit_signal('type_changed', type)

	func set_params(new_params: Vector3) -> void:
		if params != new_params:
			params = new_params
			emit_signal('params_changed', params)

	func get_default_resource_name() -> String:
		return "Push Position Modifier"

	func get_command_type() -> int:
		return CommandType.PUSH_POSITION_MODIFIER

class PopPositionModifierCommand extends PopCommand:
	func get_default_resource_name() -> String:
		return "Pop Position Modifier"

	func get_command_type() -> int:
		return CommandType.POP_POSITION_MODIFIER
