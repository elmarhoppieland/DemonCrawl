@tool
extends MarginContainer
class_name DebugToolAuraDetails


# ==============================================================================
@export var aura: Aura :
	set(value):
		aura = value
		
		if not is_node_ready():
			await ready
		
		if value:
			_cell_texture_rect.modulate = value.get_modulate()
			_title_label.text = value.get_name_id()
		else:
			_cell_texture_rect.modulate = Color.WHITE
# ==============================================================================
@onready var _title_label: Label = %TitleLabel
@onready var _cell_texture_rect: TextureRect = %CellTextureRect
# ==============================================================================

func _get_overlay() -> DebugToolsOverlay:
	var base := get_parent()
	while base != null and base is not DebugToolsOverlay:
		base = base.get_parent()
	return base


static func spawn_random(aura_script: Script) -> void:
	if not Quest.has_current():
		return
	if not Quest.get_current().has_current_stage():
		return
	
	var stage := Quest.get_current().get_current_stage()
	var cells := stage.get_cells().filter(func(cell: CellData) -> bool: return cell.is_visible() and not cell.has_aura())
	if cells.is_empty():
		return
	
	var cell: CellData = cells.pick_random()
	cell.set_aura(aura_script.new())


static func spawn_hovered(aura_script: Script) -> void:
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
	
	hovered_cell.set_aura(aura_script.new())


func _on_spawn_random_button_pressed() -> void:
	spawn_random(aura.get_script())


func _on_bind_spawn_random_button_pressed() -> void:
	_get_overlay().bind_action(spawn_random.bind(aura.get_script()))


func _on_bind_spawn_hovered_button_pressed() -> void:
	_get_overlay().bind_action(spawn_hovered.bind(aura.get_script()))
