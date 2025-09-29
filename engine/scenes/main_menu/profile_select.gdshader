shader_type canvas_item;

uniform float inversion = 0.0;

float inverted(float value) {
	return (1.0 - 2.0 * inversion) * value + inversion;
}

void fragment() {
	COLOR.rgb = vec3(inverted(COLOR.r), inverted(COLOR.g), inverted(COLOR.b));
}
