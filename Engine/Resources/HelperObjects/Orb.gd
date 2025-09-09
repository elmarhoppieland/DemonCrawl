@tool
extends Node
class_name Orb

# ==============================================================================
var position := Vector2.ZERO
# ==============================================================================
signal cleared()
# ==============================================================================

func get_quest() -> Quest:
	var base := get_parent()
	while base != null and base is not Quest:
		base = base.get_parent()
	return base


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


func notify_clicked() -> void:
	var handled := _clicked()
	
	if get_quest().has_current_stage():
		EffectManager.propagate(get_quest().get_current_stage().get_effects().orb_clicked, [self, handled])
	else:
		EffectManager.propagate(get_quest().get_stage_effects().orb_clicked, [self, handled])


func _clicked() -> bool:
	return false


func clear() -> void:
	cleared.emit()


func get_hovering_cell() -> CellData:
	if not get_quest().has_current_stage():
		return null
	
	var board := get_quest().get_current_stage().get_board()
	var cell_node := board.get_cell_at_global(board.get_global_mouse_position())
	return cell_node.get_data() if cell_node else null
