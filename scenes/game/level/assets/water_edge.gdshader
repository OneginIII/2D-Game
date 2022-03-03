shader_type canvas_item;

// This shader is used by the sand tiles to create a shoreline waves effect.
// Also used by the bomb enemy to create same waves.

uniform sampler2D edge_texture;
uniform vec4 waves_color : hint_color;
uniform float waves_speed : hint_range(0.0, 2.0) = 0.5;
uniform bool only_edge = false;

void fragment(){
	// Sampling a contour texture gradient for the edges.
	vec4 water_edge = texture(edge_texture, UV);
	// Using sine wave, time and a bit of math to create four different edge values.
	float edge = water_edge.r - (sin(TIME * -waves_speed) * 0.5 + 0.6);
	float edge2 = water_edge.r - (sin(TIME * -waves_speed) * 0.5 + 0.4);
	float edge3 = water_edge.r - (sin((TIME + 3.14) * waves_speed) * 0.5 + 0.7);
	float edge4 = water_edge.r - (sin((TIME + 3.14) * waves_speed) * 0.5 + 0.3);
	// Stepping those edge values for a sharp edge.
	edge = 1.0 - step(edge, 0.1);
	edge2 = 1.0 - step(edge2, 0.1);
	edge3 = 1.0 - step(edge3, 0.2);
	edge4 = 1.0 - step(edge4, 0.2);
	// Creating the final wave effect by using the overlap of the two edge pairs.
	vec4 final_edge = vec4((edge - edge2) + ((edge3 - edge4) * 0.5));
	// Colorizing the wave and limiting it's maximum values.
	final_edge *= waves_color;
	final_edge = min(final_edge, vec4(1.0, 1.0, 1.0, 1.0));
	// Reading the main texture.
	vec4 main_texture = texture(TEXTURE, UV);
	// The only edge boolean is used by the bomb enemy to render just the waves.
	if(only_edge){
		COLOR = final_edge
	}
	else{
		// Mixing the waves and the sand tiles textures together.
		COLOR = mix(final_edge, main_texture, main_texture.a);
	}
}