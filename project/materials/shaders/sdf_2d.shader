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

const int DRAW_DISTANCE_VISUAL = 0;
const int DRAW_DISTANCE_RAW = 1;
const int DRAW_COLOR = 2;
const int DRAW_NORMAL = 3;

const int NORMAL_NONE = 0;
const int NORMAL_FLAT = 1;
const int NORMAL_APPROX = 2;

const int COMMAND_SHAPE = 0;
const int COMMAND_TRANSFORM_PUSH = 1;
const int COMMAND_TRANSFORM_POP = 2;
const int COMMAND_CSG_PUSH = 3;
const int COMMAND_CSG_POP = 4;
const int COMMAND_DISTANCE_MODIFIER_PUSH = 5;
const int COMMAND_DISTANCE_MODIFIER_POP = 6;
const int COMMAND_POSITION_MODIFIER_PUSH = 7;
const int COMMAND_POSITION_MODIFIER_POP = 8;
const int COMMAND_MAX = 9;

const int SHAPE_CIRCLE = 0;
const int SHAPE_TRIANGLE = 1;
const int SHAPE_SQUARE = 2;
const int SHAPE_PENTAGON = 3;
const int SHAPE_HEXAGON = 4;
const int SHAPE_OCTAGON = 5;
const int SHAPE_MAX = 6;

const int CSG_UNION = 0;
const int CSG_SUBTRACTION = 1;
const int CSG_INTERSECTION = 2;
const int CSG_MAX = 3;

const int DISTANCE_MODIFIER_ROUND = 0;
const int DISTANCE_MODIFIER_ANNULATE = 1;
const int DISTANCE_MODIFIER_ELONGATE = 2;
const int DISTANCE_MODIFIER_MAX = 3;

const int POSITION_MODIFIER_ELONGATE = 0;
const int POSITION_MODIFIER_REFLECT = 1;
const int POSITION_MODIFIER_REPEAT = 2;
const int POSITION_MODIFIER_REPEAT_LIMITED = 3;
const int POSITION_MODIFIER_TWIST = 4;
const int POSITION_MODIFIER_BEND = 5;
const int POSITION_MODIFIER_MAX = 6;

uniform int draw_mode = 0;
uniform int normal_mode = 0;
uniform float normal_smoothing_factor = 1.0;

uniform float anti_alias_gradient = 1.0;
uniform float visual_sine_frequency = 100.0;
uniform float visual_surface_size = 1.0;
uniform float visual_cutoff = 0.5;
uniform float visual_min = -0.25;
uniform float visual_max = 0.5;
uniform float raw_flip = 1.0;
uniform float raw_min = 0.0;
uniform float raw_max = 1.0;
uniform float color_blend_a0 = 0.0;

uniform sampler2D data_texture;

varying vec2 position;
varying vec2 uv;

// SDF Functions
float sdf_circle(vec2 pos, float radius) {
	return length(pos) - radius;
}

float sdf_triangle(vec2 pos, float radius) { 
	float k = sqrt(3.0);
	vec2 p = pos;
	p.x = abs(p.x) - radius;
	p.y = -p.y + radius / k;
	if(p.x + k * p.y > 0.0) {
		p = vec2(p.x - k * p.y, -k * p.x - p.y) / 2.0;
	}
	p.x -= clamp(p.x, -2.0 * radius, 0.0);
	return -length(p) * sign(p.y);
}

float sdf_square(vec2 pos, vec2 extent) { 
	vec2 pos_abs = abs(pos) - extent;
    return length(max(pos_abs, 0.0)) + min(max(pos_abs.x, pos_abs.y), 0.0);
}

float sdf_pentagon(vec2 pos, float radius) {
	vec3 k = vec3(0.809016994,0.587785252,0.726542528);
	vec2 p = pos;
	p.x = abs(p.x);
	p -= 2.0 * min(dot(vec2(-k.x, k.y), p), 0.0) * vec2(-k.x, k.y);
	p -= 2.0 * min(dot(vec2(k.x, k.y), p), 0.0) * vec2(k.x, k.y);
	p -= vec2(clamp(p.x, -radius * k.z, radius * k.z), radius);
	return length(p) * sign(p.y);
}

float sdf_hexagon(vec2 pos, float radius) {
	vec3 k = vec3(-0.866025404,0.5,0.577350269);
	vec2 p = pos;
	p = abs(p);
	p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
	p -= vec2(clamp(p.x, -radius * k.z, radius * k.z), radius);
	return length(p) * sign(p.y);
}

float sdf_octagon(vec2 pos, float radius) { 
	vec3 k = vec3(-0.9238795325, 0.3826834323, 0.4142135623);
	vec2 p = pos;
	p = abs(p);
	p -= 2.0 * min(dot(vec2(k.x, k.y), p), 0.0) * vec2(k.x, k.y);
	p -= 2.0 * min(dot(vec2(-k.x, k.y), p), 0.0) * vec2(-k.x, k.y);
	p -= vec2(clamp(p.x, -radius * k.z, radius * k.z), radius);
	return length(p) * sign(p.y);
}

float shape(int function, vec2 pos, mat3 trx, vec2 size) {
	pos = (inverse(trx) * vec3(pos, 1.0)).xy;
	
	if(function == SHAPE_CIRCLE) {
		return sdf_circle(pos, size.x);
	}
	else if(function == SHAPE_TRIANGLE) {
		return sdf_triangle(pos, size.x);
	}
	else if(function == SHAPE_SQUARE) {
		return sdf_square(pos, size);
	}
	else if(function == SHAPE_PENTAGON) {
		return sdf_pentagon(pos, size.x);
	}
	else if(function == SHAPE_HEXAGON) {
		return sdf_hexagon(pos, size.x);
	}
	else if(function == SHAPE_OCTAGON) {
		return sdf_octagon(pos, size.x);
	}
}

// CSG Functions
float csg_union(float d1, float d2) {
	return min(d1, d2);
}

float csg_subtraction(float d1, float d2) {
	return max(-d1, d2);
}

float csg_intersection(float d1, float d2) {
	return max(d1, d2);
}

float csg_smooth_union(float d1, float d2, float k) {
	float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
	return mix(d2, d1, h) - k * h * (1.0 - h);
}

float csg_smooth_subtraction(float d1, float d2, float k) {
	float h = clamp(0.5 - 0.5 * (d2 + d1) / k, 0.0, 1.0);
	return mix(d2, -d1, h) + k * h * (1.0 - h);
}

float csg_smooth_intersection(float d1, float d2, float k) {
	float h = clamp(0.5 - 0.5 * (d2 - d1) / k, 0.0, 1.0);
	return mix(d2, d1, h) + k * h * (1.0 - h);
}

float csg(int function, float k, float d1, float d2) {
	if(k > 0.0) {
		if(function == CSG_UNION) {
			return csg_smooth_union(d1, d2, k);
		}
		else if(function == CSG_SUBTRACTION) {
			return csg_smooth_subtraction(d1, d2, k);
		}
		else if(function == CSG_INTERSECTION) {
			return csg_smooth_intersection(d1, d2, k);
		}
	}
	else {
		if(function == CSG_UNION) {
			return csg_union(d1, d2);
		}
		else if(function == CSG_SUBTRACTION) {
			return csg_subtraction(d1, d2);
		}
		else if(function == CSG_INTERSECTION) {
			return csg_intersection(d1, d2);
		}
	}
}

// Distance Modifier Functions
float modify_dist_round(float d, float r) {
	return d - r;
}

float modify_dist_annulate(float d, float r) {
	return abs(d) - r;
}

float modify_dist_elongate(vec2 p, float d, vec2 h) {
	vec2 q = abs(p) - h;
	return d + min(max(q.x, q.y), 0.0);
}

float modify_dist(int function, vec2 p, float d, vec2 params) {
	if(function == DISTANCE_MODIFIER_ROUND) {
		return modify_dist_round(d, params.x);
	}
	else if(function == DISTANCE_MODIFIER_ANNULATE) {
		return modify_dist_annulate(d, params.x);
	}
	else if(function == DISTANCE_MODIFIER_ELONGATE) {
		return modify_dist_elongate(p, d, params.xy);
	}
}

// Position Modifier Functions
vec2 modify_position_elongate(vec2 p, vec2 h) {
	return max(abs(p) - h, 0.0);
}

vec2 modify_position_elongate_old(vec2 p, vec2 h) {
	return p - clamp(p, -h, h);
}

vec2 modify_position_reflect(vec2 p, vec2 n) {
	n = normalize(n);
	if(dot(p, n) > 0.0) {
		return reflect(vec3(p, 0), vec3(n, 0)).xy;
	}
	return p;
}

vec2 modify_position_repeat(vec2 p, vec2 c) {
	return mod(p + 0.5 * c, c) - 0.5 * c;
}

vec2 modify_position_repeat_limited(vec2 p, vec2 l, float c) {
	return p - c * clamp(round(p / c), -l, l);
}

float square(float t) {
	return round(fract(t));
}

float saw(float t) {
	return fract(t);
}

float triangle(float t) {
	return 2.0 * abs(saw(t)) - 1.0;
}

vec2 modify_position_twist(vec2 p, vec2 t) {
	float c = cos(length(p) * t.x);
	float s = sin(length(p) * t.x);
	mat2 m = mat2(vec2(c, -s), vec2(s, c));
	return m * p;
}

vec2 modify_position_bend(vec2 p, vec2 n) {
	if(n == vec2(0)) {
		return p;
	}
	float l = length(n);
	float pp = dot(p, normalize(n));
	float c = cos(pp * l);
	float s = sin(pp * l);
	mat2 m = mat2(vec2(c, -s), vec2(s, c));
	return m * p;
}

vec2 modify_position(int function, vec2 pos, vec3 param) {
	if(function == POSITION_MODIFIER_ELONGATE) {
		return modify_position_elongate(pos, param.xy);
	}
	else if(function == POSITION_MODIFIER_REFLECT) {
		return modify_position_reflect(pos, param.xy);
	}
	else if(function == POSITION_MODIFIER_REPEAT) {
		return modify_position_repeat(pos, param.xy);
	}
	else if(function == POSITION_MODIFIER_REPEAT_LIMITED) {
		return modify_position_repeat_limited(pos, param.xy, param.z);
	}
	else if(function == POSITION_MODIFIER_TWIST) {
		return modify_position_twist(pos, param.xy);
	}
	else if(function == POSITION_MODIFIER_BEND) {
		return modify_position_bend(pos, param.xy);
	}
}

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

int get_command(int idx) {
	return int(read_data_type(DATA_COMMAND, idx).r * 255.0);
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

float get_shape_modulate_dist(int shape_ptr) { 
	return read_data_type(DATA_SHAPE_MODULATE, shape_ptr).r;
}

int get_csg_type(int csg_ptr) {
	if(csg_ptr == -1) {
		return 0;
	}
	
	return int(read_data_type(DATA_CSG_TYPE, csg_ptr).x * 255.0);
}

vec2 get_csg_smoothing(int csg_ptr) {
	if(csg_ptr == -1) {
		return vec2(0);
	}
	
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

// SDF Stack Machine
void evaluate_sdf(in vec2 pos, in float frag_width, out float dist, out vec4 color) {
	int command_count = get_command_count();
	
	mat3 transform = mat3(
		vec3(1, 0, 0),
		vec3(0, 1, 0),
		vec3(0, 0, 1)
	);
	
	vec2 pos_stack[10];
	pos_stack[0] = pos;
	
	float dist_stack[10];
	dist_stack[0] = INFINITY;
	
	int pos_ptr = 0;
	int dist_ptr = 0;
	
	int shape_ptr = -1;
	int transform_ptr = -1;
	int csg_ptr = -1;
	int distance_modifier_ptr = -1;
	int position_modifier_ptr = -1;
	
	vec4 out_color = vec4(0);
	float color_weight = 0.0;
	
	for(int i = 0; i < command_count; ++i) {
		int command = get_command(i);
				
		if(command == COMMAND_SHAPE) {
			// Fetch shape data
			shape_ptr++;
			
			// Evaluate shape
			float out_dist = shape(get_shape_type(shape_ptr), pos_stack[pos_ptr], transform, get_shape_size(shape_ptr));
			
			vec2 csg_smoothing = get_csg_smoothing(csg_ptr);
			
			// Color
			float delta = dist_stack[dist_ptr] - out_dist;
			
			float band_size = max(max(csg_smoothing.y, 0.0), frag_width);
			
			float k = 1.0;
			k *= smoothstep(color_blend_a0 - band_size, color_blend_a0 + band_size, delta);
			
			vec4 shape_color = get_shape_color(shape_ptr);
			float modulate_dist = get_shape_modulate_dist(shape_ptr);
			shape_color.xyz *= mix(1.0, abs(out_dist), modulate_dist);
			
			out_color -= color_weight * out_color * k;
			out_color += shape_color * k;
			color_weight += k + color_weight * -k;
			
			// CSG against existing shape
			if(dist_stack[dist_ptr] == INFINITY) {
				dist_stack[dist_ptr] = out_dist;
			}
			else {
				dist_stack[dist_ptr] = csg(get_csg_type(csg_ptr), csg_smoothing.x, out_dist, dist_stack[dist_ptr]);
			}
		}
		else if(command == COMMAND_TRANSFORM_PUSH) {
			transform_ptr++;
			transform *= get_transform(transform_ptr);
		}
		else if(command == COMMAND_TRANSFORM_POP) {
			transform *= inverse(get_transform(transform_ptr));
			transform_ptr++;
		}
		else if(command == COMMAND_CSG_PUSH) {
			csg_ptr++;
			dist_ptr++;
			dist_stack[dist_ptr] = INFINITY;
		}
		else if(command == COMMAND_CSG_POP) {
			if(dist_stack[dist_ptr - 1] == INFINITY) {
				dist_stack[dist_ptr - 1] = dist_stack[dist_ptr];
			}
			else {
				dist_stack[dist_ptr - 1] = csg(
					get_csg_type(csg_ptr - 1),
					get_csg_smoothing(csg_ptr - 1).x,
					dist_stack[dist_ptr],
					dist_stack[dist_ptr - 1]
				);
			}
			
			csg_ptr++;
			dist_ptr--;
		}
		else if(command == COMMAND_DISTANCE_MODIFIER_PUSH) {
			distance_modifier_ptr++;
			dist_ptr++;
			dist_stack[dist_ptr] = INFINITY;
		}
		else if(command == COMMAND_DISTANCE_MODIFIER_POP) {
			dist_stack[dist_ptr] = modify_dist(
				get_distance_modifier_type(distance_modifier_ptr),
				(inverse(transform) * vec3(pos_stack[pos_ptr - 1], 1.0)).xy,
				dist_stack[dist_ptr],
				get_distance_modifier_params(distance_modifier_ptr)
			);
			
			if(dist_stack[dist_ptr - 1] == INFINITY) {
				dist_stack[dist_ptr - 1] = dist_stack[dist_ptr];
			}
			else {
				dist_stack[dist_ptr - 1] = csg(
					get_csg_type(csg_ptr),
					get_csg_smoothing(csg_ptr).x,
					dist_stack[dist_ptr],
					dist_stack[dist_ptr - 1]
				);
			}
			
			dist_ptr--;
			distance_modifier_ptr++;
		}
		else if(command == COMMAND_POSITION_MODIFIER_PUSH) {
			position_modifier_ptr++;
			
			pos_ptr++;
			pos_stack[pos_ptr] = (transform * vec3(modify_position(get_position_modifier_type(position_modifier_ptr), (inverse(transform) * vec3(pos_stack[pos_ptr - 1], 1.0)).xy, get_position_modifier_params(position_modifier_ptr)), 1.0)).xy;
		}
		else if(command == COMMAND_POSITION_MODIFIER_POP) {
			position_modifier_ptr++;
			
			pos_stack[pos_ptr] = vec2(0);
			pos_ptr--;
		}
	}
	
	dist = dist_stack[dist_ptr];
	color = out_color / color_weight;
}

// Color Functions
float remap(float a1, float a2, float b1, float b2, float s) {
	return b1 + (s - a1) * (b2 - b1) / (a2 - a1);
}

vec4 color_distance_raw(float dist, float frag_width) {
	float imin;
	float imax;
	if(raw_min != 0.0) {
		imin = remap(min(raw_max, 0.0), raw_min, 0.0, 1.0, dist);
	}
	if(raw_max != 0.0) {
		imax = remap(max(raw_min, 0.0), raw_max, 0.0, 1.0, dist);
	}
	return vec4(raw_flip * vec3(mix(imax, imin, step(dist, 0))), 1.0);
}

vec4 color_distance_visual(float dist, float frag_width) {
	vec3 color;
	if(abs(dist) < frag_width * visual_surface_size) {
		color = vec3(smoothstep(frag_width * visual_surface_size, 0.0, abs(dist)));
	}
	else {
		vec3 base_color = mix(vec3(1.0, 0.25, 0.25),  vec3(0.25, 0.25, 1.0), step(dist, 0));
		float sine = sin(dist * visual_sine_frequency) * 0.5 + 0.5;
		
		float imin = remap(min(visual_max, 0.0), visual_min, 0.0, 1.0, dist);
		float imax = remap(max(visual_min, 0.0), visual_max, 0.0, 1.0, dist);
		
		color = base_color * mix(0.5, 1.0, sine) * mix(imax, imin, step(dist, 0));
	}
	
	float alpha = smoothstep(visual_cutoff, visual_cutoff - frag_width * anti_alias_gradient, dist);
	return vec4(color, alpha);
}

vec4 color(int function, vec2 pos, float frag_width) {
	float dist;
	vec4 color;
	evaluate_sdf(pos, frag_width, dist, color);
	
	if(function == DRAW_DISTANCE_RAW) {
		return color_distance_raw(dist, frag_width);
	}
	else if(function == DRAW_DISTANCE_VISUAL) {
		return color_distance_visual(dist, frag_width);
	}
	else if(function == DRAW_COLOR) {
		return vec4(color.xyz * triangle(dist * 5.0), 1.0);
	}
}

// Normal functions
vec3 normal_none(vec2 pos, float frag_width) {
	return vec3(0, 0, 0);
}

vec3 normal_flat(vec2 pos, float frag_width) {
	return vec3(0, 0, 1);
}

vec3 normal_approx(vec2 pos, float frag_width) {
	/*
	float h = frag_width * normal_smoothing_factor;
	vec2 k = vec2(1,-1) * h;
	return normalize(vec3(normalize(
		k.xyy * evaluate_sdf(pos + k.xy, frag_width) +
		k.yyx * evaluate_sdf(pos + k.yy, frag_width) +
		k.yxy * evaluate_sdf(pos + k.yx, frag_width) +
		k.xxx * evaluate_sdf(pos + k.xx, frag_width)
	).xy, 1.0));
	*/
	return vec3(pos, 1.0);
}

vec3 normal(int function, vec2 pos, float frag_width) {
	if(function == NORMAL_NONE) {
		return normal_none(pos, frag_width);
	}
	if(function == NORMAL_FLAT) {
		return normal_flat(pos, frag_width);
	}
	else if(function == NORMAL_APPROX) {
		return normal_approx(pos, frag_width);
	}
}

// Shader functions
void vertex() {
	position = VERTEX;
	uv = UV;
}

void fragment() {
	vec4 out_color = vec4(1);
	vec3 out_normal = vec3(0, 0, 1);
	
	float frag_width = fwidth(length(position));
	vec3 normal = normal(normal_mode, position, frag_width);
	if(draw_mode == DRAW_NORMAL) {
		out_color = vec4(normal, 1.0);
	}
	else {
		out_color = color(draw_mode, position, frag_width);
		out_normal = normal;
	}
	
	COLOR = out_color;
	NORMAL = out_normal;
}