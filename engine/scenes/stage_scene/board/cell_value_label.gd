@tool
extends Label
class_name CellValueLabel

# ==============================================================================
const GLEAN_MODULATE_ALPHA := 0.8
# ==============================================================================
var _cell: CellData = null :
	set(value):
		if _cell and _cell.changed.is_connected(_update):
			_cell.changed.disconnect(_update)
		
		_cell = value
		
		_update()
		if value:
			value.changed.connect(_update)
# ==============================================================================

func _enter_tree() -> void:
	var cell := get_parent()
	while cell != null and cell is not Cell:
		cell = cell.get_parent()
	if cell == null:
		return
	
	_set_cell(cell)
	cell.data_assigned.connect(_set_cell.bind(cell))


func _exit_tree() -> void:
	var cell := get_parent()
	while cell != null and cell is not Cell:
		cell = cell.get_parent()
	if cell == null:
		return
	
	cell.data_assigned.disconnect(_set_cell.bind(cell))


func _set_cell(cell: Cell) -> void:
	_cell = cell.get_data()


func _update() -> void:
	if not _cell:
		return
	
	if _cell.is_value_visible():
		show()
		text = str(_cell.value)
		
		var gleaned := _cell.is_hidden()
		modulate.a = int(not gleaned) + int(gleaned) * GLEAN_MODULATE_ALPHA
	else:
		hide()
