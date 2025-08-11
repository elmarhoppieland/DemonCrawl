@tool
extends Mastery
class_name Auramancer

# ==============================================================================
const AURA_COUNT := 3
# ==============================================================================

func _enter_tree() -> void:
	super()
	
	if not active:
		return
	
	get_quest().get_immunity().add_blocker(Aura, &"negative_effect", _negative_effect)
	get_quest().get_stage_effects().generated.connect(_stage_generate)
	#get_quest().get_stage_effects().cell_second_interacted.connect(_cell_second_interact)
	get_quest().get_stage_effects().cell_aura_removed.connect(_aura_remove)
	
	get_quest().get_action_manager().register(_action)


func _exit_tree() -> void:
	super()
	
	if not active:
		return
	
	get_quest().get_immunity().remove_blocker(Aura, &"negative_effect", _negative_effect)
	get_quest().get_stage_effects().generated.disconnect(_stage_generate)
	#get_quest().get_stage_effects().cell_second_interacted.disconnect(_cell_second_interact)
	get_quest().get_stage_effects().cell_aura_removed.disconnect(_aura_remove)
	
	get_quest().get_action_manager().unregister(_action)


func _action(object: Object) -> Array[Callable]:
	if level < 1:
		return []
	if object is not CellData:
		return []
	if not object.has_aura():
		return []
	return [_cell_second_interact.bind(object)]


func _negative_effect(_effect: Callable) -> bool:
	if level < 1:
		return true
	return false


func _stage_generate() -> void:
	if level < 1:
		return
	
	var stage := get_quest().get_current_stage()
	
	var cells: Array[CellData] = []
	cells.assign(stage.get_cells().filter(func(cell: CellData) -> bool: return not cell.has_aura()))
	var picked := PackedInt32Array()
	for i in get_attributes().mastery_activations + AURA_COUNT:
		var idx := randi() % (cells.size() - picked.size())
		for j in picked:
			if j <= idx:
				idx += 1
		
		picked.insert(picked.bsearch(idx), idx)
		
		cells[idx].apply_aura(DemonCrawl.get_full_registry().auras.pick_random().new())


func _cell_second_interact(cell: CellData) -> void:
	if level < 1:
		return
	
	cell.clear_aura()


func _aura_remove(aura: Aura) -> void:
	if level < 2:
		return
	
	apply_repeated_effect(aura, aura.get_cell().value + get_attributes().mastery_activations)


func _ability() -> void:
	for cell in get_quest().get_current_stage().get_cells():
		if cell.has_aura() and cell.is_visible():
			apply_repeated_effect(cell.get_aura(), cell.value + get_attributes().mastery_activations)


func _get_max_charges() -> int:
	return 3


func _can_use_ability() -> bool:
	return get_quest().has_current_stage()


func apply_effect(aura: Aura) -> void:
	match aura.get_script():
		Sanctified:
			get_stats().gain_souls(1, self)
		Burning:
			get_quest().get_current_stage().get_cells().filter(func(cell: CellData) -> bool:
				return cell.is_occupied() and cell.is_hidden() and cell.has_monster()
			).pick_random().open(true)


func apply_repeated_effect(aura: Aura, repeats: int) -> void:
	match aura.get_script():
		Sanctified:
			Quest.get_current().get_stats().gain_souls(repeats, self)
		_:
			for i in repeats:
				apply_effect(aura)
