@tool
extends CellObject
class_name CellDiamond

# ==============================================================================

func _get_texture() -> CompressedTexture2D:
	return ResourceLoader.load("res://Assets/sprites/diamond.png")


func _interact() -> void:
	var value: int = Effects.get_diamond_value(5, get_cell())
	get_quest_instance().coins += value
	
	get_cell().add_text_particle("+" + str(value), TextParticles.ColorPreset.COINS)
	
	#var texture := get_texture()
	#var start_pos := get_cell().get_global_transform_with_canvas().origin + get_cell().size * get_cell().get_global_transform_with_canvas().get_scale() / 2
	#var sprite := Stage.get_current().get_scene().tween_texture(texture, start_pos, Stats.get_coin_position(), 0.4)
	#sprite.create_tween().tween_property(sprite, "scale", Vector2.ZERO, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	clear()


func _get_charitable_amount() -> int:
	return 5


func _is_charitable() -> bool:
	return true
