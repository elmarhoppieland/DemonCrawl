@tool
extends MarginContainer
class_name DebugToolObjectDetails


# ==============================================================================
@export var object: CellObject :
	set(value):
		object = value
		
		if not is_node_ready():
			await ready
		
		for child in _texture_node_display.get_children():
			if child is CellObject:
				child.queue_free()
		
		if value:
			_texture_node_display.display_as_child(value)
			_title_label.text = value.get_name_id()
		else:
			_texture_node_display.texture_node = null
# ==============================================================================
@onready var _title_label: Label = %TitleLabel
@onready var _texture_node_display: TextureNodeDisplay = %TextureNodeDisplay
# ==============================================================================

func _get_overlay() -> DebugToolsOverlay:
	var base := get_parent()
	while base != null and base is not DebugToolsOverlay:
		base = base.get_parent()
	return base


static func spawn_random(object_script: Script) -> void:
	if not Quest.has_current():
		return
	if not Quest.get_current().has_current_stage():
		return
	
	var stage := Quest.get_current().get_current_stage()
	var cells := stage.get_cells().filter(func(cell: CellData) -> bool: return cell.is_visible() and cell.is_empty())
	if cells.is_empty():
		return
	
	var cell: CellData = cells.pick_random()
	cell.set_object(object_script.new())


static func spawn_hovered(object_script: Script) -> void:
	if not Quest.has_current():
		return
	if not Quest.get_current().has_current_stage():
		return
	
	var board := Quest.get_current().get_current_stage().get_board()
	if not board:
		return
	
	var hovered_cell := board.get_hovered_cell()
	if not hovered_cell:
		return
	
	hovered_cell.set_object(object_script.new())


func _on_spawn_random_button_pressed() -> void:
	spawn_random(object.get_script())


func _on_bind_spawn_random_button_pressed() -> void:
	_get_overlay().bind_action(spawn_random.bind(object.get_script()))


func _on_bind_spawn_hovered_button_pressed() -> void:
	_get_overlay().bind_action(spawn_hovered.bind(object.get_script()))
