extends MasteryUnlocker

# ==============================================================================

func _init() -> void:
	mastery = "novice"


func cell_open(cell: Cell) -> void:
	if cell.cell_value >= 4:
		unlock(1)
	if cell.cell_value >= 5:
		unlock(2)
	if cell.cell_value >= 6:
		unlock(3)
