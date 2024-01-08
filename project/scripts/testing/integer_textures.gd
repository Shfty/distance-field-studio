extends MeshInstance2D
tool

export(PoolByteArray) var integers := PoolByteArray([
	0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120
]) setget set_integers

func set_integers(new_integers: PoolByteArray) -> void:
	if integers != new_integers:
		integers = new_integers
		update()

func update() -> void:
	var integer_image = Image.new()
	integer_image.create_from_data(integers.size() / 4, 1, false, Image.FORMAT_RGBA8, integers)

	var integer_texture = ImageTexture.new()
	integer_texture.create_from_image(integer_image, 0)

	var shader_material = ShaderMaterial.new()
	shader_material.set_shader(preload("res://project/materials/shaders/integer_textures.shader"))
	shader_material.set_shader_param('sampler2d', integer_texture)
	set_material(shader_material)
