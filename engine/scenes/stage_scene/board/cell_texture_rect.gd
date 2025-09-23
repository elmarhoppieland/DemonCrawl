@tool
extends TextureRect
class_name CellTextureRect

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

func _init() -> void:
	theme_changed.connect(_update)


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
	
	if _cell.is_visible():
		texture = get_theme_icon("bg", "Cell")
		return
	if _cell.is_flagged():
		texture = get_theme_icon("flag_bg", "Cell")
		return
	if _cell.is_checking():
		texture = get_theme_icon("checking", "Cell")
		return
	
	texture = get_theme_icon("hidden", "Cell")


func _validate_property(property: Dictionary) -> void:
	if property.name == "texture":
		property.usage |= PROPERTY_USAGE_READ_ONLY
