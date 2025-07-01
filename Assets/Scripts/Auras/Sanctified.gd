extends Aura
class_name Sanctified

# ==============================================================================

func _apply(_cell: CellData) -> void:
	Quest.get_current().get_attributes().morality += 1


func _cell_load(cell: CellData) -> void:
	Effects.MutableSignals.restore_life.connect(_restore_life.bind(cell))


func _cell_unload(cell: CellData) -> void:
	Effects.MutableSignals.restore_life.disconnect(_restore_life.bind(cell))


func _get_modulate() -> Color:
	return Color(0.939394, 0.72093, 0.28, 1)


func _restore_life(life: int, _source: Object, cell: CellData) -> int:
	if cell.is_occupied():
		return life + 1
	return life
