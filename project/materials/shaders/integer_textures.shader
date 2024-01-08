shader_type canvas_item;

uniform sampler2D sampler2d;

void fragment() {
	vec4 sample = texture(sampler2d, UV);
	
	COLOR = vec4(vec3(sample.r), 1.0);
}