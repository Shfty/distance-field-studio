class_name DistanceFieldInstance
extends MeshInstance
tool

# Public Members
var billboard_size := Vector2.ONE * 4.0 setget set_billboard_size
var distance_field = null setget set_distance_field

# Private Members
var shader_material: ShaderMaterial = null

# Setters
func set_billboard_size(new_billboard_size: Vector2) -> void:
	if new_billboard_size != billboard_size:
		billboard_size = new_billboard_size
		get_mesh().set_size(get_billboard_size())

func set_distance_field(new_distance_field: Resource) -> void:
	if not new_distance_field:
		distance_field = null
		update_shader_material()
	elif new_distance_field is DistanceField and distance_field != new_distance_field:
		if distance_field and distance_field.is_connected("generated_shader_changed", self, "update_shader_material"):
			distance_field.disconnect("generated_shader_changed", self, "update_shader_material")
		distance_field = new_distance_field
		if distance_field and not distance_field.is_connected("generated_shader_changed", self, "update_shader_material"):
			distance_field.connect("generated_shader_changed", self, "update_shader_material")
		update_shader_material()

# Getters
func get_billboard_size() -> Vector3:
	return Vector3(billboard_size.x, billboard_size.y, max(billboard_size.x, billboard_size.y))

# Overrides
func _init() -> void:
	mesh = CubeMesh.new()
	mesh.set_size(get_billboard_size())
	mesh.flip_faces = true

	shader_material = ShaderMaterial.new()
	set_material_override(shader_material)

	update_mesh()
	update_shader_material()

func _get_property_list() -> Array:
	return [
		{
			'name': 'billboard_size',
			'type': TYPE_VECTOR2
		},
		{
			'name': 'distance_field',
			'type': TYPE_OBJECT
		}
	]

# Business Logic
func update_mesh() -> void:
	mesh.set_size(get_billboard_size())

func update_shader_material() -> void:
	if distance_field and distance_field.generated_shader:
		shader_material.set_shader(distance_field.generated_shader)
		visible = true
	else:
		shader_material.set_shader(null)
		visible = false
