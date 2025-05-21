@tool
extends Texture2D
class_name Orb

# ==============================================================================
var position := Vector2.ZERO
# ==============================================================================

func get_speed() -> float:
	return Quest.get_current().get_orb_manager().orb_speed


func _export_packed() -> Array:
	return []


func create_sprite() -> OrbSprite:
	var sprite := _create_sprite()
	if not sprite:
		return null
	sprite.orb = self
	sprite.direction = randf_range(-PI, PI)
	sprite.position = position
	return sprite


func _create_sprite() -> OrbSprite:
	return null
