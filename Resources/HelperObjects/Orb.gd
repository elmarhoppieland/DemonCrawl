@tool
extends Texture2D
class_name Orb

# ==============================================================================
var speed_override := NAN
# ==============================================================================

func get_speed() -> float:
	if is_nan(speed_override):
		return Quest.get_current().get_orb_manager().orb_speed
	return speed_override


func _export_packed() -> Array:
	return []


func create_sprite() -> OrbSprite:
	var sprite := _create_sprite()
	if not sprite:
		return null
	sprite.orb = self
	sprite.direction = randf_range(-PI, PI)
	return sprite


func _create_sprite() -> OrbSprite:
	return null
