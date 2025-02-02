shader_type spatial;

uniform vec3 lower_colour : source_color = vec3(1.0);
uniform vec3 upper_colour : source_color = vec3(1.0);
uniform float max_height = 10.0;

void fragment() {
	vec4 world_pos = INV_PROJECTION_MATRIX * vec4(VERTEX, 1.0);
	float height = world_pos.y;
	ALBEDO = mix(lower_colour, upper_colour, (height/max_height)).xyz;
}

void light(){
	SPECULAR_LIGHT = vec3(0.0);
	DIFFUSE_LIGHT = vec3(0.0);
}
