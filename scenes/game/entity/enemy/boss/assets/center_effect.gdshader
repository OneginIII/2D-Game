shader_type canvas_item;
render_mode blend_add;

// This shader is used by the central light of the boss enemy.

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
	// Sampling the radial gradient sprite texture.
	vec4 gradient = texture(TEXTURE, UV);
	// Creating a black color variable.
	vec4 black = vec4(0.0, 0.0, 0.0, gradient.a);
	// Sampling a gradient texture. Using the radial gradient texture to map the gradient.
	// Using time and modulo operation to repeatedly scroll the texture with adjustable speed.
	vec4 rainbow = texture(rainbow_gradient, mod((gradient.rg * rainbow_scale) - (TIME * rainbow_speed), 1.0));
	// Another similar scrolling gradient for creating a pulsing effect.
	vec4 pulse = texture(pulse_gradient, mod((gradient.rg * -pulse_scale) + (TIME * pulse_speed), 1.0));
	// Using the radial gradient to create a gradient expanding from center for blending.
	float rainbow_mix = clamp((1.0 - gradient.r) - 1.0 + 2.0 * rainbow_blend, 0.0, 1.0);
	// Adding rainbow gradient and pulses together. Adjustable mixing with black.
	COLOR = mix(black, rainbow, rainbow_mix);
	COLOR += mix(black, pulse, pulse_blend);
	// Another radial gradient expanding from center for blending.
	float total_mix = clamp((1.0 - gradient.r) * total_blend, 0.0, 1.0);
	// Mixing the the rainbow and pulse results with a final radial fade to black.
	COLOR = mix(black, COLOR, total_mix);
	// Fixing alpha values to the original sprite texture values.
	COLOR = vec4(COLOR.r, COLOR.b, COLOR.g, gradient.a);
}