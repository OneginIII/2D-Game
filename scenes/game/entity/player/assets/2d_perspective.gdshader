shader_type canvas_item;

uniform float gradient_effect : hint_range(-0.1, 0.1) = 0.0;
uniform float warp_effect : hint_range(-0.1, 0.1) = 0.0;

float centered_gradient(float v){
	float gradient = (v - 0.5) * 2.0;
	return gradient;
}

void vertex(){
	vec2 warp = vec2(centered_gradient(UV.x), centered_gradient(UV.y));
	// VERTEX += vec2(abs(warp.x) * warp_effect, warp.x * (warp.y * warp_effect));
}

void fragment(){
	float gradient = centered_gradient(UV.x);
	vec2 warp = vec2(centered_gradient(UV.x), centered_gradient(UV.y));
	gradient *= gradient_effect;
	vec4 image = texture(TEXTURE, UV + vec2(abs(warp.x) * warp_effect, warp.x * (warp.y * warp_effect)));
	COLOR = image + vec4(gradient, gradient, gradient, 0.0);
}