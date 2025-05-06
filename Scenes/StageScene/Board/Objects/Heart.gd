@tool
extends CellObject
class_name Heart

# ==============================================================================
const ANIM_DURATION := 0.7
const TEXTURE_WIDTH := 10
# ==============================================================================
var tween: Tween
# ==============================================================================

func _get_texture() -> CompressedTexture2D:
	return preload("res://Assets/sprites/heart.png")


func _ready() -> void:
	while not get_cell():
		await cell_changed
	
	tween = get_cell().create_tween().set_loops().set_trans(Tween.TRANS_QUAD)
	tween.tween_property(get_cell().get_object_texture_rect().get_2d_anchor(), "scale", Vector2.ONE * (1 + 2.0 / TEXTURE_WIDTH), ANIM_DURATION / 2).set_ease(Tween.EASE_IN)
	tween.tween_property(get_cell().get_object_texture_rect().get_2d_anchor(), "scale", Vector2.ONE, ANIM_DURATION / 2).set_ease(Tween.EASE_OUT)


func _clear() -> void:
	get_cell().get_object_texture_rect().get_2d_anchor().scale = Vector2.ONE
	tween.kill()


func _get_palette() -> Texture2D:
	if not get_cell():
		return null
	return get_cell().get_theme_icon("heart_palette", "Cell")


func _interact() -> void:
	if get_stats().life >= get_stats().max_life:
		Toasts.add_toast("You're already at max life!", null)
		return
	
	var life := Effects.get_heart_value()
	
	get_stats().life_restore(life, self)
	get_cell().add_text_particle("+" + str(life), TextParticles.ColorPreset.LIFE)
	tween_texture_to(GuiLayer.get_statbar().get_heart_position())
	clear()
