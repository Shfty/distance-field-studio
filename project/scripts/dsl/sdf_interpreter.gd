class_name DistanceFieldInterpreter

# Public Members
var sdf_program: DistanceFieldProgram

# Change Functions
func before_sdf_program_change() -> void:
	pass

func after_sdf_program_change() -> void:
	pass

# Business Logic
func interpret() -> void:
	pass

func connect_checked(source: Object, signal_name: String, target: Object, method_name: String, binds: Array = []) -> void:
	if not source.is_connected(signal_name, target, method_name):
		source.connect(signal_name, target, method_name, binds)

func disconnect_checked(source: Object, signal_name: String, target: Object, method_name: String) -> void:
	if source.is_connected(signal_name, target, method_name):
		source.disconnect(signal_name, target, method_name)
