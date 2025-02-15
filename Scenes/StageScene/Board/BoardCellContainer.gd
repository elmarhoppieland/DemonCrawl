@tool
extends GridContainer
class_name BoardCellContainer

# ==============================================================================
var _hovered_cell: Cell : get = get_hovered_cell
var _pressed_cell: Cell
# ==============================================================================
signal stage_finished()
# ==============================================================================

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"_stage_instance" when owner is Board:
			property.usage |= PROPERTY_USAGE_READ_ONLY
		"columns":
			property.usage |= PROPERTY_USAGE_READ_ONLY


func _ready() -> void:
	if not get_stage():
		return
	
	columns = get_stage().size.x
	
	for i in get_stage().area():
		var cell := get_stage().get_instance().create_cell(i)
		cell.mouse_entered.connect(func() -> void:
			_hovered_cell = cell
		)
		cell.mouse_exited.connect(func() -> void:
			if _hovered_cell == cell:
				_hovered_cell = null
		)
		add_child(cell)
	
	#for anchor: String in ["anchor_left", "anchor_top", "anchor_right", "anchor_bottom"]:
		#set(anchor, 0)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if _hovered_cell and not _pressed_cell and Input.is_action_just_pressed("cell_open"):
		_pressed_cell = _hovered_cell
		
		if not _hovered_cell.is_revealed():
			_hovered_cell.check()
		elif not _hovered_cell.is_occupied():
			for cell in _hovered_cell.get_nearby_cells():
				cell.check()
		else:
			_pressed_cell = null
	
	if _pressed_cell and Input.is_action_just_released("cell_open"):
		if _pressed_cell == _hovered_cell:
			if _pressed_cell.is_hidden():
				_open_cell(_pressed_cell)
			elif _pressed_cell.is_solved():
				for cell in _pressed_cell.get_nearby_cells():
					_open_cell(cell)
			else:
				for cell in _pressed_cell.get_nearby_cells():
					cell.uncheck()
		elif _pressed_cell.is_hidden():
			_pressed_cell.uncheck()
		else:
			for cell in _pressed_cell.get_nearby_cells():
				cell.uncheck()
		
		_pressed_cell = null
	
	if _hovered_cell and Input.is_action_just_pressed("cell_flag"):
		if _hovered_cell.get_mode() == Cell.Mode.FLAGGED:
			_hovered_cell.unflag()
		elif _hovered_cell.is_revealed():
			if _hovered_cell.is_flag_solved():
				for cell in _hovered_cell.get_nearby_cells():
					if cell.get_mode() == Cell.Mode.HIDDEN:
						Stage.get_current().get_instance().remove_flagless()
					cell.flag()
		else:
			if _hovered_cell.get_mode() == Cell.Mode.HIDDEN:
				Stage.get_current().get_instance().remove_flagless()
			_hovered_cell.flag()
			get_stage().get_instance().remove_flagless()


func get_hovered_cell() -> Cell:
	return _hovered_cell


func get_stage() -> Stage:
	return Stage.get_current()


# this function is needed because doing this recursively causes a stack overflow
# if the stage is too big (also this is faster than recursive anyway)
func _open_cell(cell: Cell) -> void:
	if cell.is_flagged():
		return
	
	if not get_stage().get_instance().is_generated():
		get_stage().get_instance().generate(cell.get_board_position())
	
	if cell.get_value() != 0:
		cell.open()
		_after_open_cell()
		return
	
	var to_explore: Array[Cell] = [cell]
	var visited: Array[Cell] = []
	
	while not to_explore.is_empty():
		var current_cell := to_explore.pop_back() as Cell
		
		visited.append(current_cell)
		current_cell.open()
		
		if current_cell.get_value() != 0 or current_cell.get_object() is CellMonster:
			continue
		
		for c in current_cell.get_nearby_cells():
			if c in visited or c in to_explore or c.is_revealed() or c.is_flagged():
				continue
			to_explore.append(c)
	
	_after_open_cell()


func _after_open_cell() -> void:
	if get_stage().get_instance().is_finished():
		for cell: Cell in get_children():
			cell.flag()
		stage_finished.emit()
