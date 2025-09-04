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
	return preload("res://Assets/Sprites/heart.png")


func _enter_tree() -> void:
	if get_parent() is not CellData:
		return
	
	tween = create_tween().set_loops().set_trans(Tween.TRANS_QUAD)
	tween.tween_method(get_cell().scale_object, 1.0, 1 + 2.0 / TEXTURE_WIDTH, ANIM_DURATION * 0.5).set_ease(Tween.EASE_IN)
	tween.tween_method(get_cell().scale_object, 1 + 2.0 / TEXTURE_WIDTH, 1.0, ANIM_DURATION * 0.5).set_ease(Tween.EASE_OUT)
	#tween.tween_interval(ANIM_DURATION * 0.2)


func _exit_tree() -> void:
	if get_parent() is not CellData:
		return
	
	get_cell().scale_object(1.0)
	tween.kill()


func _get_palette() -> Texture2D:
	return get_theme_icon("heart_palette", "Cell")


func _interact() -> void:
	var success := true
	
	if get_stats().life < get_stats().max_life:
		var life: int = EffectManager.propagate(get_quest().get_stage_effects().get_object_value, [self, 1, &"heal"], 1)
		life = get_stats().life_restore(life, self)
		get_cell().add_text_particle("+" + str(life), TextParticles.ColorPreset.LIFE)
		
		EffectManager.propagate(get_stage_instance().get_effects().object_used, [self])
	else:
		success = EffectManager.propagate(get_stage_instance().get_effects().handle_object_interact_failed, [self, false], 1)
		EffectManager.propagate(get_stage_instance().get_effects().object_interact_failed, [self, success])
		
		if not success:
			Toasts.add_toast("You're already at max life!", null)
	
	if success:
		use()


func _can_interact() -> bool:
	return true


func use() -> void:
	tween_texture_to(GuiLayer.get_statbar().get_heart_position())
	clear()
