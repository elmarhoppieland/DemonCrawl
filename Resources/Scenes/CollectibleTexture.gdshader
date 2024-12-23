shader_type canvas_item;

uniform float glow = 0.0;

void fragment() {
	for (int i = 0; i < 3; i++) {
		COLOR[i] = (1.0 - COLOR[i]) * glow + COLOR[i];
	}
}
