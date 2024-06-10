shader_type canvas_item;

uniform bool color_transform_enabled = false;
uniform vec3 color_transform = vec3(0);

void fragment() {
	if (color_transform_enabled) {
		COLOR.rgb = length(COLOR.rgb) / sqrt(3) * color_transform;
	}
}
