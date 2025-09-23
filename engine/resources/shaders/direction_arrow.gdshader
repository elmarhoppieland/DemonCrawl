shader_type canvas_item;

uniform float run_time = 1.0;
uniform float wait_time = 1.0;
uniform float start_offset = -1.0;
uniform float end_offset = 1.0;

void vertex() {
	VERTEX.x += 2.0 * (start_offset + (end_offset - start_offset) * sqrt(mod(TIME, run_time + wait_time) / run_time));
}

void fragment() {
	if (mod(TIME, run_time + wait_time) > run_time) {
		COLOR.a = 0.0;
	}
	else if (mod(TIME, run_time + wait_time) < run_time * 0.5) {
		if (COLOR.a > 0.01) {
			COLOR.a = 2.0 * mod(TIME, run_time + wait_time) / run_time;
		}
	}
	else {
		if (COLOR.a > 0.01) {
			COLOR.a = 2.0 - 2.0 * mod(TIME, run_time + wait_time) / run_time;
		}
	}
}
