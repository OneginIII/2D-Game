shader_type canvas_item;
render_mode blend_add;

uniform sampler2D rainbow_gradient : hint_albedo;
uniform sampler2D pulse_gradient : hint_albedo;
uniform float rainbow_scale : hint_range(0.0, 10.0) = 0.25;
uniform float rainbow_speed : hint_range(0.0, 10.0) = 1.0;
uniform float rainbow_blend : hint_range(0.0, 1.0) = 0.5;
uniform float pulse_scale : hint_range(0.0, 10.0) = 0.25;
uniform float pulse_speed : hint_range(0.0, 2.0) = 1.0;
uniform float pulse_blend : hint_range(0.0, 1.0) = 1.0;
uniform float total_blend : hint_range(0.0, 10.0) = 1.0;

void fragment(){
	vec4 gradient = texture(TEXTURE, UV);
	vec4 black = vec4(0.0, 0.0, 0.0, gradient.a);
	vec4 rainbow = texture(rainbow_gradient, mod((gradient.rg * rainbow_scale) - (TIME * rainbow_speed), 1.0));
	vec4 pulse = texture(pulse_gradient, mod((gradient.rg * -pulse_scale) + (TIME * pulse_speed), 1.0));
	float rainbow_mix = clamp((1.0 - gradient.r) - 1.0 + 2.0 * rainbow_blend, 0.0, 1.0);
	COLOR = mix(black, rainbow, rainbow_mix);
	COLOR += mix(black, pulse, pulse_blend);
	float total_mix = clamp((1.0 - gradient.r) * total_blend, 0.0, 1.0);
	COLOR = mix(black, COLOR, total_mix);
	COLOR = vec4(COLOR.r, COLOR.b, COLOR.g, gradient.a);
}