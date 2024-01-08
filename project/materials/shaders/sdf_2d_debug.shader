shader_type canvas_item;
render_mode blend_mix;

const float INFINITY = 1.0 / 0.0;

const int DATA_COUNT = 0;
const int DATA_COMMAND = 1;
const int DATA_TRANSFORM = 2;
const int DATA_SHAPE_TYPE = 3;
const int DATA_SHAPE_SIZE = 4;
const int DATA_SHAPE_COLOR = 5;
const int DATA_SHAPE_GRADIENT = 6;
const int DATA_SHAPE_MODULATE = 7;
const int DATA_CSG_TYPE = 8;
const int DATA_CSG_SMOOTHING = 9;
const int DATA_DISTANCE_MODIFIER_TYPE = 10;
const int DATA_DISTANCE_MODIFIER_PARAM = 11;
const int DATA_POSITION_MODIFIER_TYPE = 12;
const int DATA_POSITION_MODIFIER_PARAM = 13;
const int DATA_MAX = 14;

const int COMMAND_MAX = 9;
const int SHAPE_MAX = 6;
const int CSG_MAX = 3;
const int DISTANCE_MODIFIER_MAX = 3;
const int POSITION_MODIFIER_MAX = 6;

uniform sampler2D data_texture;

varying vec2 uv;

// Data Texture Functions
vec4 read_data(ivec2 data_uv) {
	return texelFetch(data_texture, data_uv, 0);
}

ivec2 get_data_uv(int i) {
	ivec2 data_texture_size = textureSize(data_texture, 0);
	return ivec2(
		i % data_texture_size.x,
		i / data_texture_size.x
	);
}

vec4 read_data_idx(int i) {
	return read_data(get_data_uv(i));
}

int get_data_ptr(int type) {
	return int(read_data_idx(type).r);
}

vec4 read_data_type(int type, int i) {
	return read_data_idx(get_data_ptr(type) + i);
}

int get_command_count() {
	return int(read_data_type(DATA_COUNT, 0).r * 255.0);
}

int get_transform_count() {
	return int(read_data_type(DATA_COUNT, 1).r * 255.0);
}

int get_shape_count() {
	return int(read_data_type(DATA_COUNT, 2).r * 255.0);
}

int get_csg_count() {
	return int(read_data_type(DATA_COUNT, 3).r * 255.0);
}

int get_distance_modifier_count() {
	return int(read_data_type(DATA_COUNT, 4).r * 255.0);
}

int get_position_modifier_count() {
	return int(read_data_type(DATA_COUNT, 5).r * 255.0);
}

void get_command(in int idx, out int command, out int command_param) {
	ivec4 data = ivec4(read_data_type(DATA_COMMAND, idx) * 255.0);
	command = data.r;
	command_param = data.g;
}

mat3 get_transform(int transform_ptr) {
	int base_idx = transform_ptr * 3;
	vec2 x = read_data_type(DATA_TRANSFORM, base_idx).xy;
	vec2 y = read_data_type(DATA_TRANSFORM, base_idx + 1).xy;
	vec2 origin = read_data_type(DATA_TRANSFORM, base_idx + 2).xy;
	return mat3(
		vec3(x, 0.0),
		vec3(y, 0.0),
		vec3(origin, 1.0)
	);
}

int get_shape_type(int shape_ptr) {
	return int(read_data_type(DATA_SHAPE_TYPE, shape_ptr).x * 255.0);
}

vec2 get_shape_size(int shape_ptr) {
	return read_data_type(DATA_SHAPE_SIZE, shape_ptr).xy;
}

vec4 get_shape_color(int shape_ptr) { 
	return read_data_type(DATA_SHAPE_COLOR, shape_ptr);
}

vec4 get_shape_gradient(int shape_ptr) { 
	return read_data_type(DATA_SHAPE_GRADIENT, shape_ptr);
}

vec2 get_shape_modulate(int shape_ptr) { 
	return read_data_type(DATA_SHAPE_MODULATE, shape_ptr).xy;
}

int get_csg_type(int csg_ptr) {
	return int(read_data_type(DATA_CSG_TYPE, csg_ptr).x * 255.0);
}

vec2 get_csg_smoothing(int csg_ptr) {
	return read_data_type(DATA_CSG_SMOOTHING, csg_ptr).xy;
}

int get_distance_modifier_type(int distance_modifier_ptr) {
	return int(read_data_type(DATA_DISTANCE_MODIFIER_TYPE, distance_modifier_ptr).x * 255.0);
}

vec2 get_distance_modifier_params(int distance_modifier_ptr) {
	return read_data_type(DATA_DISTANCE_MODIFIER_PARAM, distance_modifier_ptr).xy;
}

int get_position_modifier_type(int position_modifier_ptr) {
	return int(read_data_type(DATA_POSITION_MODIFIER_TYPE, position_modifier_ptr).x * 255.0);
}

vec3 get_position_modifier_params(int position_modifier_ptr) {
	return read_data_type(DATA_POSITION_MODIFIER_PARAM, position_modifier_ptr).xyz;
}

// Debug Draw Functions
void modulate_alpha(float x, inout float alpha) {
	float frag_width = fwidth(x) * 4.0;
	alpha *= smoothstep(frag_width, -frag_width, (abs(0.5 - mod(x, 1.0)) - 0.5) * 2.0);
}

void get_data_row(in int count, out int row, inout float alpha) {
	float row_v = (1.0 - uv.y) * float(count);
	row = int(row_v);
	modulate_alpha(row_v, alpha);
}

void get_data_column(in int count, out int column, inout float alpha) {
	float column_u = uv.x * float(count);
	column = int(column_u);
	modulate_alpha(column_u, alpha);
}

// Shader Functions
void vertex() {
	uv = UV;
}

void fragment() {
	vec3 color;
	float alpha = 1.0;
	
	int row = -1;
	int column = -1;
	int transform_offset = 2;
	
	get_data_row(DATA_MAX, row, alpha);
	
	if(row == DATA_COUNT) {
		get_data_column(6, column, alpha);
		switch(column) {
			case 0:
				color = vec3(float(get_command_count()) / 10.0);
				break;
			case 1:
				color = vec3(float(get_transform_count()) / 10.0);
				break;
			case 2:
				color = vec3(float(get_shape_count()) / 10.0);
				break;
			case 3:
				color = vec3(float(get_csg_count()) / 10.0);
				break;
			case 4:
				color = vec3(float(get_distance_modifier_count()) / 10.0);
				break;
			case 5:
				color = vec3(float(get_position_modifier_count()) / 10.0);
				break;
			default:
				break;
		}
	}
	else if(row == DATA_COMMAND) {
		get_data_column(get_command_count(), column, alpha);
		int command, command_param;
		get_command(column, command, command_param);
		color = vec3(float(command) / float(COMMAND_MAX));
	}
	else if(row == DATA_TRANSFORM) {
		get_data_column(get_transform_count(), column, alpha);
		mat3 trx = get_transform(column);
		color = trx[0] / 4.0;
	}
	else if(row == DATA_TRANSFORM + 1) {
		get_data_column(get_transform_count(), column, alpha);
		mat3 trx = get_transform(column);
		color = trx[1] / 4.0;
	}
	else if(row == DATA_TRANSFORM + 2) {
		get_data_column(get_transform_count(), column, alpha);
		mat3 trx = get_transform(column);
		color = trx[2] / 4.0;
	}
	else if(row == DATA_SHAPE_TYPE + transform_offset) {
		get_data_column(get_shape_count(), column, alpha);
		color = vec3(float(get_shape_type(column)) / float(SHAPE_MAX));
	}
	else if(row == DATA_SHAPE_SIZE + transform_offset) {
		get_data_column(get_shape_count(), column, alpha);
		color = vec3(get_shape_size(column), 0.0);
	}
	else if(row == DATA_SHAPE_COLOR + transform_offset) {
		get_data_column(get_shape_count(), column, alpha);
		color = get_shape_color(column).xyz;
	}
	else if(row == DATA_SHAPE_GRADIENT + transform_offset) {
		get_data_column(get_shape_count(), column, alpha);
		color = get_shape_gradient(column).xyz;
	}
	else if(row == DATA_SHAPE_MODULATE + transform_offset) {
		get_data_column(get_shape_count(), column, alpha);
		color = vec3(get_shape_modulate(column), 0.0);
	}
	else if(row == DATA_CSG_TYPE + transform_offset) {
		get_data_column(get_csg_count(), column, alpha);
		color = vec3(float(get_csg_type(column)) / float(CSG_MAX));
	}
	else if(row == DATA_CSG_SMOOTHING + transform_offset) {
		get_data_column(get_csg_count(), column, alpha);
		color = vec3(get_csg_smoothing(column), 0.0);
	}
	else if(row == DATA_DISTANCE_MODIFIER_TYPE + transform_offset) {
		get_data_column(get_distance_modifier_count(), column, alpha);
		color = vec3(float(get_distance_modifier_type(column)) / float(DISTANCE_MODIFIER_MAX));
	}
	else if(row == DATA_DISTANCE_MODIFIER_PARAM + transform_offset) {
		get_data_column(get_distance_modifier_count(), column, alpha);
		color = vec3(get_distance_modifier_params(column), 1.0);
	}
	else if(row == DATA_POSITION_MODIFIER_TYPE + transform_offset) {
		get_data_column(get_position_modifier_count(), column, alpha);
		color = vec3(float(get_position_modifier_type(column)) / float(POSITION_MODIFIER_MAX));
	}
	else if(row == DATA_POSITION_MODIFIER_PARAM + transform_offset) {
		get_data_column(get_position_modifier_count(), column, alpha);
		color = vec3(get_position_modifier_params(column));
	}
	
	COLOR = vec4(color, alpha);
}