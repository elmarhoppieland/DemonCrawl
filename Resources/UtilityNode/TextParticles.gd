@tool
extends CPUParticles2D
class_name TextParticles

# ==============================================================================
enum ColorPreset {
	FREE,
	COINS
}
# ==============================================================================
const PRESET_DATA := {
	ColorPreset.COINS: {
		"font_color": Color(0.972549, 0.898039, 0.533333, 1),
		"outline_color": Color(0.498039, 0.188235, 0.00392157, 1)
	}
}
# ==============================================================================
@export var text := "" :
	set(value):
		text = value
		
		if not is_node_ready():
			await ready
		
		particle_label.text = text
		
		if not is_inside_tree():
			await tree_entered
		await get_tree().process_frame
		
		particle_viewport.size = particle_label.size + Vector2(1, 0)
@export var text_color_preset := ColorPreset.FREE :
	set(value):
		text_color_preset = value
		
		if not is_node_ready():
			await ready
		
		for key in PRESET_DATA.get(value, {}):
			particle_label.label_settings[key] = PRESET_DATA[value][key]
@export var particle_viewport: SubViewport
@export var particle_label: Label
# ==============================================================================
