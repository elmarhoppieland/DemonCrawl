@tool
extends Control
class_name CellAuraModulator

# ==============================================================================

func _ready() -> void:
	get_cell().changed.connect(_update)
	_update()


func _update() -> void:
	if get_cell() and get_cell().get_mode() == Cell.Mode.VISIBLE and get_cell().has_aura():
		modulate = get_cell().get_aura().get_modulate()
	else:
		modulate = Color.WHITE


func get_cell() -> Cell:
	return owner
