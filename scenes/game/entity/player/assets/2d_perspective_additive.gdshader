shader_type canvas_item;
render_mode blend_add;

// Deprecated. Was used by the player gun lights, but now the player ship uses a viewport texture.
// Essentially identical to 2D perspective shader, just with an additive blend mode.

uniform float gradient_effect : hint_range(-0.1, 0.1) = 0.0;
uniform float warp_effect : hint_range(-0.1, 0.1) = 0.0;

float centered_gradient(float v){
	float gradient = (v - 0.5) * 2.0;
	return gradient;
}

void fragment(){
	vec2 warp = vec2(centered_gradient(UV.x), centered_gradient(UV.y));
	vec4 image = texture(TEXTURE, UV + vec2(abs(warp.x) * warp_effect, warp.x * (warp.y * warp_effect)));
	COLOR = image;
}