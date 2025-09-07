@tool
extends CellObjectTextureRectBase
class_name CellObjectTextureRect

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


func _is_visible() -> bool:
	return _cell and _cell.is_occupied() and _cell.is_visible()


func _get_texture() -> Texture2D:
	return _cell.get_object().get_texture()


func _get_material() -> Material:
	return _cell.get_object().get_material()


func _get_annotation_text() -> String:
	return _cell.get_object().get_annotation_text()


func get_2d_anchor() -> Node2D:
	return get_parent()
