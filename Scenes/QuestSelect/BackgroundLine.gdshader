shader_type canvas_item;


void fragment() {
	COLOR.a *= clamp(2.0 - UV.x * 2.0, 0, 1);
}
