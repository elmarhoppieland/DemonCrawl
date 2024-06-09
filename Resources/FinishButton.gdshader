shader_type canvas_item;

uniform vec3 color = vec3(1);
uniform float speed = 0.667;

void fragment() {
	COLOR = texture(TEXTURE, UV - vec2(mod(TIME * speed, 1.0), 0.0));
	
	COLOR.a *= 1.0 - 2.0 * abs(UV.x - 0.5);
	COLOR.a *= 1.0 - abs(UV.y - 0.5);
	
	COLOR.rgb = color;
}
