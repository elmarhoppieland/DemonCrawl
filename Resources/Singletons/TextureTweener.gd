extends Node
class_name TextureTweener

# ==============================================================================

func tween_texture(texture: Texture2D, from: Vector2, to: Vector2, duration: float, scale: float = 1.0) -> Tween:
	var sprite := Sprite2D.new()
	sprite.scale = scale * Vector2.ONE
	
	sprite.texture = texture
	if texture.has_method("get_material"):
		sprite.material = texture.get_material()
	
	add_child(sprite)
	
	var tween := sprite.create_tween()
	tween.tween_property(sprite, "position", to, duration).from(from)
	tween.tween_callback(sprite.queue_free)
	tween.tween_property(sprite, "scale", Vector2.ZERO, duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	return tween
