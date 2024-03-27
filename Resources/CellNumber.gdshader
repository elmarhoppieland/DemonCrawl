shader_type canvas_item;

uniform vec3 default_color = vec3(1.0);

void fragment() {
	if (COLOR.rgb != default_color) {
		COLOR.a = ceil(COLOR.a);
	}
}
