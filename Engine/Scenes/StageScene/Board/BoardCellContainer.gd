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
			if _hovered_cell == cell.get_data():
				_hovered_cell = null
		)
		add_child(cell)
	
	#for anchor: String in ["anchor_left", "anchor_top", "anchor_right", "anchor_bottom"]:
		#set(anchor, 0)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if _hovered_cell:
		if Input.is_action_just_pressed("interact"):
			_pressed_cell = _hovered_cell
			
			var actions := _hovered_cell.get_actions()
			if actions.size() > 0:
				actions[0].call()
		if Input.is_action_just_pressed("secondary_interact"):
			var actions := _hovered_cell.get_actions()
			if actions.size() > 1:
				actions[1].call()
		
		if Input.is_action_just_released("secondary_interact"):
			var actions := _hovered_cell.get_release_actions()
			if actions.size() > 1:
				actions[1].call()
	
	if _pressed_cell and Input.is_action_just_released("interact"):
		var actions := _pressed_cell.get_release_actions()
		if actions.size() > 0:
			actions[0].call()


func get_hovered_cell() -> CellData:
	return _hovered_cell
