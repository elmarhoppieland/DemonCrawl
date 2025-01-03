@tool
extends CellObject
class_name CellCoin

# ==============================================================================

func _get_texture() -> TextureSequence:
	var texture := TextureSequence.new()
	texture.atlas = preload("res://Assets/sprites/coin.png")
	texture.size = Cell.CELL_SIZE
	return texture


func _get_palette() -> CompressedTexture2D:
	return get_cell().get_theme_icon("coin_palette", "Cell")


func _get_animation_delta() -> float:
	return 0.1


func _interact() -> void:
	var value: int = Effects.get_coin_value(1, get_cell())
	get_quest_instance().coins += value
	
	get_cell().add_text_particle("+" + str(value), TextParticles.ColorPreset.COINS)
	
	#var texture := get_texture()
	#var start_pos := get_cell().get_global_transform_with_canvas().origin + get_cell().size * get_cell().get_global_transform_with_canvas().get_scale() / 2
	#var sprite := Stage.get_current().get_scene().tween_texture(texture, start_pos, Stats.get_coin_position(), 0.4, get_cell().get_sprite_material())
	#var tween := sprite.create_tween().set_parallel()
	#tween.tween_method(func(delta: float):
		#texture.animate(get_animation_delta() * texture.get_tiles_area(), delta)
	#, 0.0, 0.4, 0.4)
	#tween.tween_property(sprite, "scale", Vector2.ZERO, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	#cell.global_sprite.texture = get_texture()
	#var tween := cell.global_sprite.create_tween()
	#tween.tween_property(cell.global_sprite, "position", Stats.get_coin_position() / 4, 0.4).from(cell.global_position)
	#tween.parallel().tween_property(cell.global_sprite, "scale", Vector2.ZERO, 0.4)
	#tween.parallel().tween_method(func(delta: float):
		#cell.global_sprite.texture.animate(get_animation_delta(), delta)
	#, 0.0, 0.4, 0.4)
	#tween.tween_callback(cell.global_sprite.hide)
	#cell.global_sprite.show()
	
	clear()


func _get_charitable_amount() -> int:
	return 1


func _is_charitable() -> bool:
	return true


func _animate(time: float) -> void:
	get_texture().animate(0.5, time)
