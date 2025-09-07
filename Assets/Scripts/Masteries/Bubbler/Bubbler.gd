@tool
extends Mastery
class_name Bubbler

# ==============================================================================

func _enable() -> void:
	get_quest().get_stage_effects().finish_pressed.connect(_stage_finish)
	get_quest().get_stage_effects().orb_clicked.connect(_orb_clicked)


func _disable() -> void:
	get_quest().get_stage_effects().finish_pressed.disconnect(_stage_finish)
	get_quest().get_stage_effects().orb_clicked.disconnect(_orb_clicked)


func _stage_finish() -> void:
	if level < 1:
		return
	
	for cell in get_quest().get_current_stage().get_cells():
		if cell.is_visible() and cell.value == 0 and cell.is_occupied() and cell.get_object() is Loot:
			get_quest().get_orb_manager().register_orb(Bubble.new(cell.get_object()))


func _orb_clicked(orb: Orb, handled: bool) -> void:
	if level < 2:
		return
	if orb is not Bubble:
		return
	if not handled:
		return
	
	var cell := orb.get_hovering_cell()
	var hidden_cells: Array[CellData] = []
	hidden_cells.assign(cell.get_nearby_cells().filter(func(c: CellData) -> bool: return c.is_hidden()))
	hidden_cells.shuffle()
	if hidden_cells.size() > cell.value:
		hidden_cells.resize(cell.value)
	for i in hidden_cells:
		i.open(true)


func _ability() -> void:
	for orb in get_quest().get_orb_manager().get_orbs():
		var new_orb: Orb = orb.duplicate()
		get_quest().get_orb_manager().register_orb(new_orb)
