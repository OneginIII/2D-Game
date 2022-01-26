shader_type canvas_item;
render_mode blend_mix;

uniform float speed : hint_range(0.0, 25.0) = 10.0;
uniform float amount : hint_range(0.0, 1.0) = 0.2;
uniform float brightness : hint_range(0.0, 5.0) = 1.0;

void vertex(){
	VERTEX.y *= (sin(TIME * speed) * amount) + 1.0 + amount;
}

void fragment(){
	COLOR = texture(TEXTURE, UV) * vec4(brightness, brightness, brightness, 1.0);
}