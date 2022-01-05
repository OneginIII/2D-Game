shader_type canvas_item;

uniform sampler2D shine_gradient;
uniform float shine_scale : hint_range(0.1, 10.0) = 5.0;
uniform float shine_speed : hint_range(0.1, 10.0) = 1.0;
uniform float shine_rotation = 45.0;

vec2 rotateUV(vec2 uv, float rotation, vec2 mid){
	return vec2(
		cos(rotation) * (uv.x - mid.x) + sin(rotation) * (uv.y - mid.y) + mid.x,
		cos(rotation) * (uv.y - mid.y) - sin(rotation) * (uv.x - mid.x) + mid.y
	);
}

void fragment(){
	vec2 shine_uv = (UV * shine_scale);
	shine_uv = rotateUV(shine_uv, shine_rotation, vec2(0.5));
	shine_uv -= shine_speed * TIME;
	shine_uv = mod(shine_uv, vec2(1.0));
	vec4 shine_color = texture(shine_gradient, shine_uv);
	shine_color = clamp(shine_color, vec4(0.0), vec4(1.0));
	COLOR = texture(TEXTURE, UV) + shine_color * vec4(1.0, 1.0, 1.0, 0.0);
}