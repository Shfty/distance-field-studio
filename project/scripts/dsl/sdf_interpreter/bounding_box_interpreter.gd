class_name BoundingBoxInterpreter
extends DistanceFieldInterpreter

signal rect_changed()

var rect: Rect2 setget set_rect

var transform_stack := []
var distance_modifier_stack := []
var position_modifier_stack := []

func before_sdf_program_change() -> void:
	if not sdf_program:
		return

	var connections = get_incoming_connections()
	for connection in connections:
		if connection.source in sdf_program.commands:
			disconnect_checked(connection.source, connection.signal_name, self, connection.method_name)

func after_sdf_program_change() -> void:
	for command in sdf_program.commands:
		if command is DistanceFieldDSL.ShapeCommand:
			connect_checked(command, 'type_changed', self, 'command_property_changed')
			connect_checked(command, 'size_changed', self, 'command_property_changed')
		elif command is DistanceFieldDSL.PushTransformCommand:
			connect_checked(command, 'transform_changed', self, 'command_property_changed')
		elif command is DistanceFieldDSL.PushDistanceModifierCommand:
			connect_checked(command, 'type_changed', self, 'command_property_changed')
			connect_checked(command, 'params_changed', self, 'command_property_changed')
		elif command is DistanceFieldDSL.PushPositionModifierCommand:
			connect_checked(command, 'type_changed', self, 'command_property_changed')
			connect_checked(command, 'params_changed', self, 'command_property_changed')

	command_property_changed(null)

func command_property_changed(value) -> void:
	interpret()

func set_rect(new_rect: Rect2) -> void:
	if rect != new_rect:
		rect = new_rect
		emit_signal('rect_changed')

func interpret() -> void:
	var transform := Transform2D()
	transform_stack = []

	var new_rect = Rect2()
	var has_rect := false

	for command in sdf_program.commands:
		if command is DistanceFieldDSL.ShapeCommand:
			var shape_rect: Rect2
			match command.type:
				DistanceFieldDSL.ShapeCommand.Type.SQUARE:
					shape_rect = Rect2(-command.size, command.size * 2.0)
				_:
					var size = Vector2(command.size.x, command.size.x)
					shape_rect = Rect2(-size, size * 2.0)

			shape_rect = transform.xform(shape_rect)
			if not has_rect:
				new_rect = shape_rect
				has_rect = true
			else:
				new_rect = new_rect.merge(shape_rect)
		elif command is DistanceFieldDSL.PushTransformCommand:
			if not 'transform' in command:
				return

			transform_stack.append(transform)
			transform = transform * command.transform
		elif command is DistanceFieldDSL.PopTransformCommand:
			transform = transform_stack.pop_back()
		elif command is DistanceFieldDSL.PushDistanceModifierCommand:
			distance_modifier_stack.append(command)
		elif command is DistanceFieldDSL.PopDistanceModifierCommand:
			var distance_modifier = distance_modifier_stack.pop_back()
			match distance_modifier.type:
				DistanceFieldDSL.PushDistanceModifierCommand.Type.ROUND:
					new_rect = new_rect.grow(distance_modifier.params.x)
				DistanceFieldDSL.PushDistanceModifierCommand.Type.ANNULATE:
					new_rect = new_rect.grow(distance_modifier.params.x)
		elif command is DistanceFieldDSL.PushPositionModifierCommand:
			position_modifier_stack.append(command)
		elif command is DistanceFieldDSL.PopPositionModifierCommand:
			var position_modifier = position_modifier_stack.pop_back()
			match position_modifier.type:
				DistanceFieldDSL.PushPositionModifierCommand.Type.ELONGATE:
					new_rect = new_rect.grow_individual(
						position_modifier.params[0],
						position_modifier.params[1],
						position_modifier.params[0],
						position_modifier.params[1]
					)
				DistanceFieldDSL.PushPositionModifierCommand.Type.REPEAT:
					new_rect = new_rect.grow_individual(
						position_modifier.params[0],
						position_modifier.params[1],
						position_modifier.params[0],
						position_modifier.params[1]
					)
				DistanceFieldDSL.PushPositionModifierCommand.Type.REPEAT_LIMITED:
					new_rect = new_rect.grow_individual(
						position_modifier.params[0] * position_modifier.params[2],
						position_modifier.params[1] * position_modifier.params[2],
						position_modifier.params[0] * position_modifier.params[2],
						position_modifier.params[1] * position_modifier.params[2]
					)

	set_rect(new_rect)
