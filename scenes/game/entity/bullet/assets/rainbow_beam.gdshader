shader_type canvas_item;
render_mode blend_add;

// This shader is used by the boss enemy beam for a rainbow coloring effect.

uniform sampler2D rainbow_gradient : hint_albedo;
uniform float rainbow_speed : hint_range(0.0, 10.0) = 1.0;
uniform float rainbow_blend : hint_range(0.0, 1.0) = 0.5;
uniform vec4 currect_color : hint_color;

void fragment(){
	// Reading the sprite texture.
	vec4 color = texture(TEXTURE, UV);
	// Multiplying the texture by a sampled color from a gradient texture.
	// Using modulated time with adjustable speed to scroll through the gradient values.
	vec4 rainbow_color = color * texture(rainbow_gradient, vec2(mod(TIME * rainbow_speed, 1.0), 0.0));
	// Finally mixing the original texture with the colored one by an adjustable amount.
	vec4 blended_color = mix(color, rainbow_color, rainbow_blend);
	COLOR = blended_color;
}