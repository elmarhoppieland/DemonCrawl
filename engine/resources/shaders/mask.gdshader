shader_type canvas_item;

uniform sampler2D mask : filter_nearest;

void fragment() {
	vec4 mask_color = texture(mask, UV);
	COLOR *= mask_color;
}
