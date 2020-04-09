class_name DistanceFieldUtil

enum GLSLType {
	FLOAT,
	VEC2,
	VEC3,
	VEC4,
	INT,
	IVEC2,
	IVEC3,
	IVEC4,
	UINT,
	UVEC2,
	UVEC3,
	UVEC4,
	BOOL,
	BVEC2,
	BVEC3,
	BVEC4,
	MAT2,
	MAT3,
	MAT4,
	SAMPLER2D,
	ISAMPLER2D,
	USAMPLER2D,
	SAMPLER2D_ARRAY,
	ISAMPLER2D_ARRAY,
	USAMPLER2D_ARRAY,
	SAMPLER3D,
	ISAMPLER3D,
	USAMPLER3D,
	SAMPLER_CUBE
}

const GLSL_TYPE_STRING_MAP := {
	GLSLType.FLOAT: 'float',
	GLSLType.VEC2: 'vec2',
	GLSLType.VEC3: 'vec3',
	GLSLType.VEC4: 'vec4',
	GLSLType.INT: 'int',
	GLSLType.IVEC2: 'ivec2',
	GLSLType.IVEC3: 'ivec3',
	GLSLType.IVEC4: 'ivec4',
	GLSLType.UINT: 'uint',
	GLSLType.UVEC2: 'uvec2',
	GLSLType.UVEC3: 'uvec3',
	GLSLType.UVEC4: 'uvec4',
	GLSLType.BOOL: 'bool',
	GLSLType.BVEC2: 'bvec2',
	GLSLType.BVEC3: 'bvec3',
	GLSLType.BVEC4: 'bvec4',
	GLSLType.MAT2: 'mat2',
	GLSLType.MAT3: 'mat3',
	GLSLType.MAT4: 'mat4',
	GLSLType.SAMPLER2D: 'sampler2D',
	GLSLType.ISAMPLER2D: 'isampler2D',
	GLSLType.USAMPLER2D: 'usampler2D',
	GLSLType.SAMPLER2D_ARRAY: 'sampler2DArray',
	GLSLType.ISAMPLER2D_ARRAY: 'isampler2DArray',
	GLSLType.USAMPLER2D_ARRAY: 'usampler2DArray',
	GLSLType.SAMPLER3D: 'sampler3D',
	GLSLType.ISAMPLER3D: 'isampler3D',
	GLSLType.USAMPLER3D: 'usampler3D',
	GLSLType.SAMPLER_CUBE: 'samplerCube'
}

const COLOR_BOOL = Color(0.54902, 0.65098, 0.941176)
const COLOR_INT = Color(0.490196, 0.780392, 0.941176)
const COLOR_FLOAT = Color(0.380392, 0.85098, 0.960784)
const COLOR_MATRIX = Color(0.960784, 0.658824, 0.431373)
const COLOR_OBJECT = Color(0.470588, 0.952941, 0.909804)

const GLSL_TYPE_COLOR_MAP := {
	GLSLType.FLOAT: COLOR_FLOAT,
	GLSLType.VEC2: COLOR_FLOAT,
	GLSLType.VEC3: COLOR_FLOAT,
	GLSLType.VEC4: COLOR_FLOAT,
	GLSLType.INT: COLOR_INT,
	GLSLType.IVEC2: COLOR_INT,
	GLSLType.IVEC3: COLOR_INT,
	GLSLType.IVEC4: COLOR_INT,
	GLSLType.UINT: COLOR_INT,
	GLSLType.UVEC2: COLOR_INT,
	GLSLType.UVEC3: COLOR_INT,
	GLSLType.UVEC4: COLOR_INT,
	GLSLType.BOOL: COLOR_BOOL,
	GLSLType.BVEC2: COLOR_BOOL,
	GLSLType.BVEC3: COLOR_BOOL,
	GLSLType.BVEC4: COLOR_BOOL,
	GLSLType.MAT2: COLOR_MATRIX,
	GLSLType.MAT3: COLOR_MATRIX,
	GLSLType.MAT4: COLOR_MATRIX,
	GLSLType.SAMPLER2D: COLOR_OBJECT,
	GLSLType.ISAMPLER2D: COLOR_OBJECT,
	GLSLType.USAMPLER2D: COLOR_OBJECT,
	GLSLType.SAMPLER2D_ARRAY: COLOR_OBJECT,
	GLSLType.ISAMPLER2D_ARRAY: COLOR_OBJECT,
	GLSLType.USAMPLER2D_ARRAY: COLOR_OBJECT,
	GLSLType.SAMPLER3D: COLOR_OBJECT,
	GLSLType.ISAMPLER3D: COLOR_OBJECT,
	GLSLType.USAMPLER3D: COLOR_OBJECT,
	GLSLType.SAMPLER_CUBE: COLOR_OBJECT
}

const GLSL_TYPE_COMPONENT_MAP := {
	GLSLType.FLOAT: GLSLType.FLOAT,
	GLSLType.VEC2: GLSLType.FLOAT,
	GLSLType.VEC3: GLSLType.FLOAT,
	GLSLType.VEC4: GLSLType.FLOAT,
	GLSLType.INT: GLSLType.INT,
	GLSLType.IVEC2: GLSLType.INT,
	GLSLType.IVEC3: GLSLType.INT,
	GLSLType.IVEC4: GLSLType.INT,
	GLSLType.UINT: GLSLType.UINT,
	GLSLType.UVEC2: GLSLType.UINT,
	GLSLType.UVEC3: GLSLType.UINT,
	GLSLType.UVEC4: GLSLType.UINT,
	GLSLType.BOOL: GLSLType.BOOL,
	GLSLType.BVEC2: GLSLType.BOOL,
	GLSLType.BVEC3: GLSLType.BOOL,
	GLSLType.BVEC4: GLSLType.BOOL,
	GLSLType.MAT2: GLSLType.VEC2,
	GLSLType.MAT3: GLSLType.VEC3,
	GLSLType.MAT4: GLSLType.VEC4,
	GLSLType.SAMPLER2D: GLSLType.SAMPLER2D,
	GLSLType.ISAMPLER2D: GLSLType.ISAMPLER2D,
	GLSLType.USAMPLER2D: GLSLType.USAMPLER2D,
	GLSLType.SAMPLER2D_ARRAY: GLSLType.SAMPLER2D_ARRAY,
	GLSLType.ISAMPLER2D_ARRAY: GLSLType.ISAMPLER2D_ARRAY,
	GLSLType.USAMPLER2D_ARRAY: GLSLType.USAMPLER2D_ARRAY,
	GLSLType.SAMPLER3D: GLSLType.SAMPLER3D,
	GLSLType.ISAMPLER3D: GLSLType.ISAMPLER3D,
	GLSLType.USAMPLER3D: GLSLType.USAMPLER3D,
	GLSLType.SAMPLER_CUBE: GLSLType.SAMPLER_CUBE
}

const GLSL_FLOAT_TYPES := [
	GLSLType.FLOAT,
	GLSLType.VEC2,
	GLSLType.VEC3,
	GLSLType.VEC4
]

const GLSL_INT_TYPES := [
	GLSLType.INT,
	GLSLType.IVEC2,
	GLSLType.IVEC3,
	GLSLType.IVEC4
]

const GLSL_UINT_TYPES := [
	GLSLType.UINT,
	GLSLType.UVEC2,
	GLSLType.UVEC3,
	GLSLType.UVEC4,
]

const GLSL_BOOL_TYPES := [
	GLSLType.BOOL,
	GLSLType.BVEC2,
	GLSLType.BVEC3,
	GLSLType.BVEC4
]

const GLSL_MATRIX_TYPES := [
	GLSLType.MAT2,
	GLSLType.MAT3,
	GLSLType.MAT4,
]

const GLSL_SAMPLER_TYPES := [
	GLSLType.SAMPLER2D,
	GLSLType.ISAMPLER2D,
	GLSLType.USAMPLER2D,
	GLSLType.SAMPLER2D_ARRAY,
	GLSLType.ISAMPLER2D_ARRAY,
	GLSLType.USAMPLER2D_ARRAY,
	GLSLType.SAMPLER3D,
	GLSLType.ISAMPLER3D,
	GLSLType.USAMPLER3D,
	GLSLType.SAMPLER_CUBE
]

const GLSL_VECTOR_TYPES := [
	GLSLType.VEC2,
	GLSLType.VEC3,
	GLSLType.VEC4,
	GLSLType.IVEC2,
	GLSLType.IVEC3,
	GLSLType.IVEC4,
	GLSLType.UVEC2,
	GLSLType.UVEC3,
	GLSLType.UVEC4,
	GLSLType.BVEC2,
	GLSLType.BVEC3,
	GLSLType.BVEC4,
	GLSLType.MAT2,
	GLSLType.MAT3,
	GLSLType.MAT4,
]

static func glsl_type_enum_to_string(val: int) -> String:
	return GLSL_TYPE_STRING_MAP[val]

static func glsl_type_string_to_enum(val: String) -> int:
	var idx = GLSL_TYPE_STRING_MAP.values().find(val)
	if idx == -1:
		return -1
	return GLSL_TYPE_STRING_MAP.keys()[idx]

static func glsl_type_enum_to_color(val: int) -> Color:
	return GLSL_TYPE_COLOR_MAP[val]

static func glsl_type_enum_to_component_type(val: int) -> Color:
	return GLSL_TYPE_COMPONENT_MAP[val]

static func create_control_for_glsl_type(type: int) -> Control:
	match type:
		GLSLType.BOOL:
			return VectorControl.new(VectorControl.Axis.VERTICAL, 1, VectorControl.Mode.BOOL)
		GLSLType.BVEC2:
			return VectorControl.new(VectorControl.Axis.VERTICAL, 2, VectorControl.Mode.BOOL)
		GLSLType.BVEC3:
			return VectorControl.new(VectorControl.Axis.VERTICAL, 3, VectorControl.Mode.BOOL)
		GLSLType.BVEC4:
			return VectorControl.new(VectorControl.Axis.VERTICAL, 4, VectorControl.Mode.BOOL)
		GLSLType.INT:
			return VectorControl.new(VectorControl.Axis.VERTICAL, 1, VectorControl.Mode.INTEGER)
		GLSLType.IVEC2:
			return VectorControl.new(VectorControl.Axis.VERTICAL, 2, VectorControl.Mode.INTEGER)
		GLSLType.IVEC3:
			return VectorControl.new(VectorControl.Axis.VERTICAL, 3, VectorControl.Mode.INTEGER)
		GLSLType.IVEC4:
			return VectorControl.new(VectorControl.Axis.VERTICAL, 4, VectorControl.Mode.INTEGER)
		GLSLType.UINT:
			return VectorControl.new(VectorControl.Axis.VERTICAL, 1, VectorControl.Mode.INTEGER)
		GLSLType.UVEC2:
			return VectorControl.new(VectorControl.Axis.VERTICAL, 2, VectorControl.Mode.INTEGER)
		GLSLType.UVEC3:
			return VectorControl.new(VectorControl.Axis.VERTICAL, 3, VectorControl.Mode.INTEGER)
		GLSLType.UVEC4:
			return VectorControl.new(VectorControl.Axis.VERTICAL, 4, VectorControl.Mode.INTEGER)
		GLSLType.FLOAT:
			return VectorControl.new(VectorControl.Axis.VERTICAL, 1, VectorControl.Mode.FLOAT)
		GLSLType.VEC2:
			return VectorControl.new(VectorControl.Axis.VERTICAL, 2, VectorControl.Mode.FLOAT)
		GLSLType.VEC3:
			return VectorControl.new(VectorControl.Axis.VERTICAL, 3, VectorControl.Mode.FLOAT)
		GLSLType.VEC4:
			return VectorControl.new(VectorControl.Axis.VERTICAL, 4, VectorControl.Mode.FLOAT)
		GLSLType.MAT2:
			return null
		GLSLType.MAT3:
			return null
		GLSLType.MAT4:
			return null
		GLSLType.SAMPLER2D:
			return null
		GLSLType.ISAMPLER2D:
			return null
		GLSLType.USAMPLER2D:
			return null
		GLSLType.SAMPLER2D_ARRAY:
			return null
		GLSLType.ISAMPLER2D_ARRAY:
			return null
		GLSLType.USAMPLER2D_ARRAY:
			return null
		GLSLType.SAMPLER3D:
			return null
		GLSLType.ISAMPLER3D:
			return null
		GLSLType.USAMPLER3D:
			return null
		GLSLType.SAMPLER_CUBE:
			return null

	return null

static func gdscript_value_to_glsl(prefix: String, name: String, value) -> String:
	var glsl := ""

	match typeof(value):
		TYPE_BOOL:
			glsl += "%s bool %s = %s;\n" % [prefix, name, String(value).to_lower()]
		TYPE_INT:
			glsl += "%s int %s = %s;\n" % [prefix, name, String(value)]
		TYPE_REAL:
			glsl += "%s float %s = %s;\n" % [prefix, name, String(value)]
		TYPE_VECTOR2:
			glsl += "%s vec2 %s = vec2(%s, %s);\n" % [prefix, name, String(value.x), String(value.y)]
		TYPE_VECTOR3:
			glsl += "%s vec3 %s = vec3(%s, %s, %s);\n" % [
				prefix,
				name,
				String(value.x),
				String(value.y),
				String(value.z)
			]
		TYPE_PLANE:
			glsl += "%s vec4 %s = vec4(%s, %s, %s, %s);\n" % [
				prefix,
				name,
				String(value.x),
				String(value.y),
				String(value.z),
				String(value.d)
			]
		TYPE_COLOR:
			glsl += "%s vec4 %s: hint_color = vec4(%s, %s, %s, %s);\n" % [
				prefix,
				name,
				String(value.r),
				String(value.g),
				String(value.b),
				String(value.a)
			]
		TYPE_RECT2:
			glsl += "%s mat2 %s = mat2(vec2(%s, %s), vec2(%s, %s));\n" % [
				prefix,
				name,
				String(value.position.x),
				String(value.position.y),
				String(value.size.x),
				String(value.size.y)
			]
		TYPE_TRANSFORM2D:
			glsl += "%s mat3 %s = mat3(vec3(%s, %s, 1.0), vec3(%s, %s, 1.0), vec3(%s, %s, 1.0));\n" % [
				prefix,
				name,
				String(value.x.x), String(value.x.y),
				String(value.y.x), String(value.y.y),
				String(value.origin.x), String(value.origin.y)
			]
		TYPE_TRANSFORM:
			glsl += "%s mat4 %s = mat4(vec4(%s, %s, %s, 1.0), vec4(%s, %s, %s, 1.0), vec4(%s, %s, %s, 1.0), vec4(%s, %s, %s, 1.0));\n" % [
				prefix,
				name,
				String(value.basis.x.x), String(value.basis.x.y), String(value.basis.x.z),
				String(value.basis.y.x), String(value.basis.y.y), String(value.basis.y.z),
				String(value.basis.z.x), String(value.basis.z.y), String(value.basis.z.z),
				String(value.origin.x), String(value.origin.y), String(value.origin.z),
			]
		TYPE_ARRAY:
			var prev_type := -1
			var same := true
			for i in range(0, value.size()):
				var type = typeof(value[i])
				if prev_type == -1 or type == prev_type:
					prev_type = type
					continue
				else:
					same = false
					break

			if not same:
				printerr("Cannot convert %s to %s, mismatched array types: %s" % [prefix, name, value])
				return ""

			match typeof(value[0]):
				TYPE_BOOL:
					match value.size():
						1:
							glsl += "%s bool %s = %s;\n" % [prefix, name, String(value[0]).to_lower()]
						2:
							glsl += "%s bvec2 %s = bvec2(%s, %s);\n" % [
								prefix,
								name,
								String(value[0]).to_lower(),
								String(value[1]).to_lower()
							]
						3:
							glsl += "%s bvec3 %s = bvec3(%s, %s, %s);\n" % [
								prefix,
								name,
								String(value[0]).to_lower(),
								String(value[1]).to_lower(),
								String(value[2]).to_lower()
							]
						4:
							glsl += "%s bvec4 %s = bvec4(%s, %s, %s, %s);\n" % [
								prefix,
								name,
								String(value[0]).to_lower(),
								String(value[1]).to_lower(),
								String(value[2]).to_lower(),
								String(value[3]).to_lower()
							]
		TYPE_INT_ARRAY:
			match value.size():
				1:
					glsl += "%s int %s = %s;\n" % [prefix, name, String(value[0])]
				2:
					glsl += "%s ivec2 %s = ivec2(%s, %s);\n" % [
						prefix,
						name,
						String(value[0]),
						String(value[1])
					]
				3:
					glsl += "%s ivec3 %s = ivec3(%s, %s, %s);\n" % [
						prefix,
						name,
						String(value[0]),
						String(value[1]),
						String(value[2])
					]
				4:
					glsl += "%s ivec4 %s = ivec4(%s, %s, %s, %s);\n" % [
						prefix,
						name,
						String(value[0]),
						String(value[1]),
						String(value[2]),
						String(value[3])
					]
		TYPE_REAL_ARRAY:
			match value.size():
				1:
					glsl += "%s float %s = %s;\n" % [prefix, name, String(value[0])]
				2:
					glsl += "%s vec2 %s = vec2(%s, %s);\n" % [
						prefix,
						name,
						String(value[0]),
						String(value[1])
					]
				3:
					glsl += "%s vec3 %s = vec3(%s, %s, %s);\n" % [
						prefix,
						name,
						String(value[0]),
						String(value[1]),
						String(value[2])
					]
				4:
					glsl += "%s vec4 %s = vec4(%s, %s, %s, %s);\n" % [
						prefix,
						name,
						String(value[0]),
						String(value[1]),
						String(value[2]),
						String(value[3])
					]
		TYPE_OBJECT:
			if value is Texture:
				glsl += "%s sampler2D %s: hint_albedo;\n" % [prefix, name]

	return glsl
