extends Aura
class_name Sanctified

# ==============================================================================

func _apply(_cell: CellData) -> void:
	Quest.get_current().get_attributes().morality += 1


func _cell_init(cell: CellData) -> void:
	Quest.get_current().get_stats().get_mutable_effects().life_restore.connect(_restore_life.bind(cell))


func _remove(cell: CellData) -> void:
	Quest.get_current().get_stats().get_mutable_effects().life_restore.disconnect(_restore_life.bind(cell))


func _get_modulate() -> Color:
	return Color(0.939394, 0.72093, 0.28, 1)


func _restore_life(life: int, _source: Object, cell: CellData) -> int:
	if cell.is_occupied():
		return life + 1
	return life
