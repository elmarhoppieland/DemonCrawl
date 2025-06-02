extends MasteryUnlocker
class_name NoviceUnlocker

# ==============================================================================

func _init() -> void:
	Effects.Signals.cell_open.connect(func(cell: CellData) -> void:
		if cell.value >= 4:
			unlock(1)
		if cell.value >= 5:
			unlock(2)
		if cell.value >= 6:
			unlock(3)
	)
