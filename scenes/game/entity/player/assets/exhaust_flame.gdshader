shader_type canvas_item;
render_mode blend_mix;

// Shader used by the various exhaust flame effects for player and enemies.

uniform float speed : hint_range(0.0, 25.0) = 10.0;
uniform float amount : hint_range(0.0, 1.0) = 0.2;
uniform float brightness : hint_range(0.0, 5.0) = 1.0;

// Distorting the sprite in the vertex function.
void vertex(){
	// Using a sine function and time to wave the sprite vertically.
	VERTEX.y *= (sin(TIME * speed) * amount) + 1.0 + amount;
}

// Optionally adjusting the flame brightness in the fragment function.
void fragment(){
	// Since the exhaust flame is using a mix blend mode, this is a way of making it bright.
	COLOR = texture(TEXTURE, UV) * vec4(brightness, brightness, brightness, 1.0);
}