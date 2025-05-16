@tool
extends Control
class_name CellAuraModulator

# ==============================================================================
@export var mode := Cell.Mode.INVALID :
	set(value):
		mode = value
		_update()
@export var aura: Aura = null :
	set(value):
		aura = value
		_update()
# ==============================================================================

func _ready() -> void:
	_update()


func _update() -> void:
	if mode == Cell.Mode.VISIBLE and aura != null:
		modulate = aura.get_modulate()
	else:
		modulate = Color.WHITE
