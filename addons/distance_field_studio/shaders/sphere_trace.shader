shader_type spatial;
render_mode blend_mix,depth_draw_alpha_prepass,cull_back,diffuse_burley,specular_schlick_ggx;

const float INFINITY = 1.0 / 0.0;

// Generated constants
// sphere_trace:constants

// Sphere tracing parameters

uniform int max_steps: hint_range(1, 1024) = 128;
uniform float over_relax_factor: hint_range(1,2) = 1.4;
uniform float anti_alias_gradient: hint_range(0,16) = 1.0;
uniform bool hollow = true;
uniform bool force_hit = false;

uniform bool draw_steps = false;
uniform vec4 step_min_color: hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 step_mid_color: hint_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform vec4 step_max_color: hint_color = vec4(1.0, 1.0, 1.0, 1.0);

// Continuity parameters
uniform int continuity_iterations: hint_range(0, 16) = 3;
uniform float continuity_threshold: hint_range(0.001, 1) = 0.001;

// Generated uniforms
// sphere_trace:uniforms

varying float near_plane;
varying float far_plane;
varying float instance_count;
varying vec2 texel_size;

varying mat4 world_matrix;
varying mat4 inverse_world_matrix;
varying mat3 world_basis;
varying mat3 inverse_world_basis;

varying mat4 camera_matrix;
varying mat3 camera_basis;
varying mat3 inverse_camera_basis;

varying mat4 inverse_projection_matrix;

varying float fov;
varying float aspect;

// Generated SDF library
// sphere_trace:library_modify_functions
// sphere_trace:library_signed_distance_functions

// Generated signed distance function
float sdf(vec3 IN_POSITION) {
	float OUT_DISTANCE;
	// sphere_trace:signed_distance_function
	return OUT_DISTANCE;
}

// Generated normal library
// sphere_trace:library_normal_functions

// Generated normal function
vec3 normal(vec3 IN_POSITION) {
	vec3 OUT_NORMAL;
	// sphere_trace:normal_function
	return OUT_NORMAL;
}

vec3 tangent(vec3 IN_POSITION) {
	vec3 OUT_TANGENT;
	// sphere_trace:tangent_function
	return OUT_TANGENT;
}

vec3 binormal(vec3 IN_POSITION) {
	vec3 OUT_BINORMAL;
	// sphere_trace:binormal_function
	return OUT_BINORMAL;
}

// Generated color library
// sphere_trace:library_color_functions

// Generated color functions
vec4 color(vec3 IN_POSITION, vec3 IN_NORMAL, vec3 IN_TANGENT, vec3 IN_BINORMAL) {
	vec4 OUT_COLOR = vec4(1);
	// sphere_trace:color_function
	return OUT_COLOR;
}

float metallic(vec3 IN_POSITION, vec3 IN_NORMAL, vec3 IN_TANGENT, vec3 IN_BINORMAL) {
	float OUT_METALLIC = 0.0;
	// sphere_trace:metallic_function
	return OUT_METALLIC;
}

float specular(vec3 IN_POSITION, vec3 IN_NORMAL, vec3 IN_TANGENT, vec3 IN_BINORMAL) {
	float OUT_SPECULAR = 0.5;
	// sphere_trace:specular_function
	return OUT_SPECULAR;
}

float roughness(vec3 IN_POSITION, vec3 IN_NORMAL, vec3 IN_TANGENT, vec3 IN_BINORMAL) {
	float OUT_ROUGHNESS = 1.0;
	// sphere_trace:roughness_function
	return OUT_ROUGHNESS;
}

vec3 emission(vec3 IN_POSITION, vec3 IN_NORMAL, vec3 IN_TANGENT, vec3 IN_BINORMAL) {
	vec3 OUT_EMISSION = vec3(0);
	// sphere_trace:emission_function
	return OUT_EMISSION;
}

float ao(vec3 IN_POSITION, vec3 IN_NORMAL, vec3 IN_TANGENT, vec3 IN_BINORMAL) {
	float OUT_AO = 1.0;
	// sphere_trace:ao_function
	return OUT_AO;
}

float ao_light_affect(vec3 IN_POSITION, vec3 IN_NORMAL, vec3 IN_TANGENT, vec3 IN_BINORMAL) {
	float OUT_AO_LIGHT_AFFECT = 0.0;
	// sphere_trace:ao_light_affect_function
	return OUT_AO_LIGHT_AFFECT;
}

void generate_perspective_rays(in vec3 view, out vec3 ray_origin, out vec3 ray_normal, out float pixel_radius) {
	ray_origin = inverse_world_basis * (camera_matrix[3].xyz - world_matrix[3].xyz);
    ray_normal = inverse_world_basis * camera_basis * view;
	pixel_radius = length(fwidth(view));
}

void generate_orthographic_rays(in vec2 screen_uv, out vec3 ray_origin, out vec3 ray_normal, out float pixel_radius) {
	vec3 view_origin = (inverse_projection_matrix * vec4(screen_uv * 2.0 - 1.0, 0.0, 1.0)).xyz;
	ray_origin = (inverse_world_matrix * camera_matrix * vec4(view_origin, 1.0)).xyz;
    ray_normal = inverse_world_basis * camera_basis * vec3(0, 0, 1);
	pixel_radius = length(fwidth(ray_origin));
}

void sphere_trace(in vec3 o, in vec3 d, in float pixel_radius, out float dist, out float steps, out float hit) {
	float omega = over_relax_factor;
	float t = near_plane;
	float candidate_error = INFINITY;
	float candidate_t = near_plane;
	float prev_radius = 0.0;
	float step_length = 0.0;
	float function_sign = sdf(o) < 0.0 ? -1.0 : 1.0;
	
	if(!hollow && function_sign == -1.0) {
		dist = t;
		hit = 1.0;
		return
	}
	
	int i = 0;
	for(i; i < max_steps; ++i) {
		float signed_radius = function_sign * sdf(d * t + o);
		float radius = abs(signed_radius);
		bool sor_fail = omega > 1.0 && (radius + prev_radius) < step_length;
		if(sor_fail) {
			step_length -= omega * step_length;
			omega = 1.0;
		}
		else {
			step_length = signed_radius * omega;
		}
		
		prev_radius = radius;
		
		float error = radius / t;
		
		if(!sor_fail && error < candidate_error) {
			candidate_t = t;
			candidate_error = error;
		}
		
		if(!sor_fail && error < pixel_radius || t > far_plane) {
			break;
		}
		
		t += step_length;
	}
	
	if(!force_hit)
	{
		if(candidate_error > pixel_radius) {
			float max_error = pixel_radius + (pixel_radius * anti_alias_gradient);
			if(candidate_error < max_error) {
				dist = candidate_t;
				steps = float(i);
				hit = smoothstep(max_error, pixel_radius, candidate_error);
				return
			}
			else if(t > far_plane) {
				return;
			}
		}
	}
	
	dist = candidate_t;
	steps = float(i);
	hit = 1.0;
}

vec3 continuity(vec3 p, vec3 o, vec3 d, int it, float t) {
	for(int i = 0; i < it; ++i) {
		p = p + d * (abs(sdf(p)) - length(p - o) * t);
	}
	return p;
}

void vertex() {
	near_plane = 0.05;
	far_plane = 500.0;
	
	world_matrix = WORLD_MATRIX;
	inverse_world_matrix = inverse(WORLD_MATRIX);
	world_basis = mat3(WORLD_MATRIX);
	inverse_world_basis = inverse(world_basis);
	
	camera_matrix = CAMERA_MATRIX;
	camera_basis = mat3(CAMERA_MATRIX);
	inverse_camera_basis = inverse(camera_basis);
	
	inverse_projection_matrix = INV_PROJECTION_MATRIX;
	
	fov = 2.0 * atan(1.0 / PROJECTION_MATRIX[1][1]);
	aspect = PROJECTION_MATRIX[1][1] / PROJECTION_MATRIX[0][0];
}

void fragment() {
	vec3 ray_origin, ray_normal;
	float pixel_radius;
	
	if(PROJECTION_MATRIX[3][3] == 0.0) {
		generate_perspective_rays(-VIEW, ray_origin, ray_normal, pixel_radius);
	}
	else {
		generate_orthographic_rays(SCREEN_UV, ray_origin, ray_normal, pixel_radius);
	}
	
	float dist = INFINITY;
	float steps = 0.0;
	float hit = 0.0;
	sphere_trace(ray_origin, ray_normal, pixel_radius, dist, steps, hit);
	
	vec3 pos = ray_origin + ray_normal * dist;
	pos = continuity(pos, ray_origin, ray_normal, continuity_iterations, continuity_threshold);
	
	vec3 normal = normal(pos);
	vec3 view_normal = inverse_camera_basis * world_basis * normal;
    NORMAL = view_normal;
	
	vec3 tangent = tangent(pos);
	vec3 view_tangent = inverse_camera_basis * world_basis * tangent;
	TANGENT = tangent;
	
	vec3 binormal = binormal(pos);
	vec3 view_binormal = inverse_camera_basis * world_basis * binormal;
	BINORMAL = binormal;
	
	if(draw_steps) {
		float step_factor = steps / float(max_steps);
		vec3 step_color;
		if(step_factor <= 0.5) {
			step_color = mix(step_min_color.xyz, step_mid_color.xyz, step_factor * 2.0f);
		}
		else {
			step_color = mix(step_mid_color.xyz, step_max_color.xyz, step_factor);
		}
		ALBEDO = vec3(0.0);
		EMISSION = step_color;
	}
	else {
		vec4 color = color(pos, normal, tangent, binormal);
		ALBEDO = color.rgb;
		ALPHA = color.a;
		
		METALLIC = metallic(pos, normal, tangent, binormal);
		SPECULAR = specular(pos, normal, tangent, binormal);
		ROUGHNESS = roughness(pos, normal, tangent, binormal);
		EMISSION = emission(pos, normal, tangent, binormal);
		AO = ao(pos, normal, tangent, binormal);
		AO_LIGHT_AFFECT = ao_light_affect(pos, normal, tangent, binormal);
	}
	
	ALPHA *= hit;
	
	vec4 clip_pos = PROJECTION_MATRIX * INV_CAMERA_MATRIX * world_matrix * vec4(pos, 1.0);
	DEPTH = clip_pos.z / clip_pos.w * 0.5 + 0.5;
}
