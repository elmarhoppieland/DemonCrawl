@tool
extends Sprite2D
class_name CellFlagSprite

# ==============================================================================
var _cell: CellData = null :
	set(value):
		if _cell and _cell.changed.is_connected(_update):
			_cell.changed.disconnect(_update)
		
		_cell = value
		
		_update()
		if value:
			value.changed.connect(_update)

var _initialized := false
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
	const FLAG_ANIM_DURATION := 0.1
	
	texture = owner.get_theme_icon("flag", "Cell")
	
	if not _initialized:
		visible = _cell.is_flagged()
		_initialized = true
		return
	
	if _cell.is_flagged() and not visible:
		create_tween().tween_property(self, "scale", Vector2.ONE, FLAG_ANIM_DURATION).from(Vector2.ZERO)
	
	visible = _cell.is_flagged()
