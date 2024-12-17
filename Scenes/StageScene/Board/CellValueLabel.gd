@tool
extends Label
class_name CellValueLabel

# ==============================================================================
var _mode := Cell.Mode.HIDDEN
var _value := 0
# ==============================================================================

func _ready() -> void:
	_mode = owner.get_mode()
	_value = owner.get_value()
	owner.value_changed.connect(func(value: int) -> void:
		_value = value
		_update()
	)
	owner.mode_changed.connect(func(mode: Cell.Mode) -> void:
		_mode = mode
		_update()
	)
	owner.object_changed.connect(_update.unbind(1))
	_update()


func _update() -> void:
	visible = _mode == Cell.Mode.VISIBLE and _value != 0 and not owner.is_occupied()
	text = str(_value)
