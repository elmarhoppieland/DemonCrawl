shader_type canvas_item;

void fragment() {
	COLOR = texture(TEXTURE, UV - vec2(mod(TIME / 1.5, 1.0), 0.0));
	COLOR.a *= 1.0 - 2.0 * abs(UV.x - 0.5);
	COLOR.a *= 1.0 - abs(UV.y - 0.5);
}
