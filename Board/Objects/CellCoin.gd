extends CellObject
class_name CellCoin

# ==============================================================================

func get_texture() -> TextureSequence:
	var texture := TextureSequence.new()
	texture.atlas = ResourceLoader.load("res://Assets/sprites/coin.png")
	texture.texture_size = Vector2i(16, 16)
	return texture


func get_palette() -> CompressedTexture2D:
	return cell.get_theme_icon("coin_palette", "Cell")


func get_animation_delta() -> float:
	return 0.1


func interact() -> void:
	Stats.coins += 1
	
	cell.add_text_particle("+1", TextParticles.ColorPreset.COINS)
	
	var texture := get_texture()
	var start_pos := cell.get_global_transform_with_canvas().origin + cell.size * cell.get_global_transform_with_canvas().get_scale() / 2
	var sprite := Board.tween_texture(texture, start_pos, Stats.get_coin_position(), 0.4, cell.get_sprite_material())
	var tween := sprite.create_tween().set_parallel()
	tween.tween_method(func(delta: float):
		texture.animate(get_animation_delta() * texture.get_tiles_area(), delta)
	, 0.0, 0.4, 0.4)
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
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


func get_charitable_amount() -> int:
	return 1


func is_charitable() -> bool:
	return true
