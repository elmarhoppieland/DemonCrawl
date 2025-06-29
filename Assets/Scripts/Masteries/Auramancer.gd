extends Mastery
class_name Auramancer

# ==============================================================================
const AURA_COUNT := 3
# ==============================================================================

func _quest_load() -> void:
	Immunity.add_blocker(Aura, &"negative_effect", _negative_effect)
	Effects.Signals.stage_generate.connect(_stage_generate)
	Effects.Signals.cell_second_interact.connect(_cell_second_interact)
	Effects.Signals.aura_remove.connect(_aura_remove)


func _quest_unload() -> void:
	Immunity.remove_blocker(Aura, &"negative_effect", _negative_effect)
	Effects.Signals.stage_generate.disconnect(_stage_generate)
	Effects.Signals.cell_second_interact.disconnect(_cell_second_interact)
	Effects.Signals.aura_remove.disconnect(_aura_remove)


func _negative_effect(_effect: Callable) -> bool:
	if level < 1:
		return true
	return false


func _stage_generate(stage: StageInstance) -> void:
	if level < 1:
		return
	
	var cells: Array[CellData] = []
	cells.assign(stage.cells.filter(func(cell: CellData) -> bool: return cell.is_empty() and not cell.aura))
	var picked := PackedInt32Array()
	for i in get_attributes().mastery_activations + AURA_COUNT:
		var idx := randi() % (cells.size() - picked.size())
		for j in picked:
			if j <= idx:
				idx += 1
		
		picked.insert(picked.bsearch(idx), idx)
		
		cells[idx].apply_aura(DemonCrawl.get_full_registry().get_elemental_auras().pick_random().duplicate())


func _cell_second_interact(cell: CellData) -> void:
	if not cell.aura:
		return
	if level < 1:
		return
	
	cell.aura = null


func _aura_remove(cell: CellData, aura: Aura) -> void:
	if level < 2:
		return
	
	apply_repeated_effect(aura, cell.value + get_attributes().mastery_activations)


func _ability() -> void:
	for cell in StageInstance.get_current().cells:
		if cell.aura and cell.is_visible():
			apply_repeated_effect(cell.aura, cell.value + get_attributes().mastery_activations)


func _get_max_charges() -> int:
	return 3


func _can_use_ability() -> bool:
	return StageInstance.has_current()


func apply_effect(aura: Aura) -> void:
	match aura.get_script():
		Burning:
			StageInstance.get_current().cells.filter(func(cell: CellData) -> bool:
				return cell.is_occupied() and cell.is_hidden() and cell.object is Monster
			).pick_random().open(true)


func apply_repeated_effect(aura: Aura, repeats: int) -> void:
	match aura.get_script():
		_:
			for i in repeats:
				apply_effect(aura)
