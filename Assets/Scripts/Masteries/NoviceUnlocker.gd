extends MasteryUnlocker
class_name NoviceUnlocker

# ==============================================================================

func _ready() -> void:
	Effects.Signals.cell_open.connect(_cell_open)


func _cell_open(cell: CellData) -> void:
	if cell.value >= 4:
		unlock(1)
	if cell.value >= 5:
		unlock(2)
	if cell.value >= 6:
		unlock(3)
