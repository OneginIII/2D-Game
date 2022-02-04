shader_type canvas_item;
render_mode blend_add;

uniform sampler2D rainbow_gradient : hint_albedo;
uniform float rainbow_speed : hint_range(0.0, 10.0) = 1.0;
uniform float rainbow_blend : hint_range(0.0, 1.0) = 0.5;
uniform vec4 currect_color : hint_color;

void fragment(){
	vec4 color = texture(TEXTURE, UV);
	vec4 rainbow_color = color * texture(rainbow_gradient, vec2(mod(TIME * rainbow_speed, 1.0), 0.0));
	vec4 blended_color = mix(color, rainbow_color, rainbow_blend);
	COLOR = blended_color;
}