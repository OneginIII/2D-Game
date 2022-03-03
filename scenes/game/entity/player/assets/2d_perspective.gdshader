shader_type canvas_item;

// This shader is used by the player ship for a depth perspective effect.

uniform float gradient_effect : hint_range(-0.1, 0.1) = 0.0;
uniform float warp_effect : hint_range(-0.1, 0.1) = 0.0;

// Function for creating a centered gradient from a UV value.
float centered_gradient(float v){
	float gradient = (v - 0.5) * 2.0;
	return gradient;
}

void fragment(){
	// Making a horizontal gradient based on UV's x coordinate.
	float gradient = centered_gradient(UV.x);
	// Making a 2D gradient based on UV coordinates.
	vec2 warp = vec2(centered_gradient(UV.x), centered_gradient(UV.y));
	// Adjusting horizontal gradient strength.
	gradient *= gradient_effect;
	// Sampling the sprite texture with a warping formula that distorts the image using the 2D gradient.
	// This effect works fine for a subtle change, but breaks with higher values.
	vec4 image = texture(TEXTURE, UV + vec2(abs(warp.x) * warp_effect, warp.x * (warp.y * warp_effect)));
	// Final color with the horizontal gradient added to brighten/darken the texture for a depth effect.
	COLOR = image + vec4(gradient, gradient, gradient, 0.0);
}