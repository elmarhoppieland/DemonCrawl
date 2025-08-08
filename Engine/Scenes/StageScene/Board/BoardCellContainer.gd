@tool
extends GridContainer
class_name BoardCellContainer

# ==============================================================================
@export var stage_instance: StageInstance = null :
	get:
		if stage_instance == null and StageScene.get_instance():
			return StageScene.get_instance().stage_instance
		return stage_instance
# ==============================================================================
var _hovered_cell: CellData : get = get_hovered_cell
var _pressed_cell: CellData
# ==============================================================================

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"_stage_instance" when owner is Board:
			property.usage |= PROPERTY_USAGE_READ_ONLY
		"columns":
			property.usage |= PROPERTY_USAGE_READ_ONLY


func _ready() -> void:
	if not stage_instance:
		return
	
	columns = stage_instance.get_stage().size.x
	
	for i in stage_instance.get_stage().area():
		var cell := stage_instance.create_cell(i)
		cell.mouse_entered.connect(func() -> void:
			_hovered_cell = cell.get_data()
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
				var r := _pressed_cell.open()
				if r:
					_after_open_cell()
			elif _pressed_cell.is_solved():
				var found_openable_cell := false
				for cell in _pressed_cell.get_nearby_cells():
					var r := cell.open()
					if r:
						found_openable_cell = true
				if found_openable_cell:
					_after_open_cell()
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
						stage_instance.remove_flagless()
					cell.flag()
		else:
			if _hovered_cell.get_mode() == Cell.Mode.HIDDEN:
				stage_instance.remove_flagless()
			_hovered_cell.flag()
			stage_instance.remove_flagless()


func get_hovered_cell() -> CellData:
	return _hovered_cell


func _after_open_cell() -> void:
	stage_instance.check_completed()
	
	EffectManager.propagate(stage_instance.get_effects().turn)
