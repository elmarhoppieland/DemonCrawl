shader_type canvas_item;

uniform bool palette_enabled = false;
uniform sampler2D palette;

void fragment() {
	if (palette_enabled) {
		// using the texture's R and G values to determine the UV position on the palette
		// sprites look weird this way but the shader is fast and the player doesn't see it anyway
		COLOR.rgb = texture(palette, COLOR.rg).rgb;
	}
}
