shader_type canvas_item;

void fragment() {
	if (UV.y < TEXTURE_PIXEL_SIZE.y || texture(TEXTURE, vec2(UV.x, UV.y - TEXTURE_PIXEL_SIZE.y)).a > 0.01) {
		COLOR.a = 0.0;
	}
}
