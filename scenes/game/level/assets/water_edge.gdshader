shader_type canvas_item;

uniform sampler2D edge_texture;
uniform vec4 waves_color : hint_color;
uniform float waves_speed : hint_range(0.0, 2.0) = 0.5;

void fragment(){
	vec4 water_edge = texture(edge_texture, UV);
	float edge = water_edge.r - (sin(TIME * -waves_speed) * 0.5 + 0.6);
	float edge2 = water_edge.r - (sin(TIME * -waves_speed) * 0.5 + 0.4);
	float edge3 = water_edge.r - (sin((TIME + 3.14) * waves_speed) * 0.5 + 0.7);
	float edge4 = water_edge.r - (sin((TIME + 3.14) * waves_speed) * 0.5 + 0.3);
	edge = 1.0 - step(edge, 0.1);
	edge2 = 1.0 - step(edge2, 0.1);
	edge3 = 1.0 - step(edge3, 0.2);
	edge4 = 1.0 - step(edge4, 0.2);
	vec4 final_edge = vec4((edge - edge2) + ((edge3 - edge4) * 0.5));
	final_edge *= waves_color;
	final_edge = min(final_edge, vec4(1.0, 1.0, 1.0, 1.0));
	// COLOR = vec4(edge - edge2);
	vec4 main_texture = texture(TEXTURE, UV);
	COLOR = mix(final_edge, main_texture, main_texture.a);
}