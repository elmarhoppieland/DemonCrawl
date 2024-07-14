extends CellObject
class_name CellDiamond

# ==============================================================================

func get_texture() -> CompressedTexture2D:
	return ResourceLoader.load("res://Assets/sprites/diamond.png")


func interact() -> void:
	var value: int = EffectManager.propagate_posnum("get_diamond_value", 5)
	Stats.coins += value
	
	cell.add_text_particle("+" + str(value), TextParticles.ColorPreset.COINS)
	
	var texture := get_texture()
	var start_pos := cell.get_global_transform_with_canvas().origin + cell.size * cell.get_global_transform_with_canvas().get_scale() / 2
	var sprite := Board.tween_texture(texture, start_pos, Stats.get_coin_position(), 0.4)
	sprite.create_tween().tween_property(sprite, "scale", Vector2.ZERO, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	clear()


func get_charitable_amount() -> int:
	return 5


func is_charitable() -> bool:
	return true
