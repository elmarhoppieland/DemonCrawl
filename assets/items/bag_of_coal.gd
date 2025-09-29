@tool
extends OmenItem

# ==============================================================================
const COAL := preload("res://assets/items/coal.tres")
# ==============================================================================

func _enable() -> void:
	get_quest().get_attributes().property_changed.connect(_attribute_changed)


func _disable() -> void:
	get_quest().get_attributes().property_changed.disconnect(_attribute_changed)


func _attribute_changed(attribute: StringName, value: Variant) -> void:
	if attribute == &"morality":
		_morality_changed(value)


func _morality_changed(morality: int) -> void:
	if morality >= get_quest().get_attributes().morality:
		return
	if not is_charged():
		return
	
	gain_item(COAL.create())
	
	for item in get_items():
		if item.get_script() != COAL.get_script():
			continue
		var cells := get_stage_instance().get_cells().filter(func(cell: CellData) -> bool: return cell.get_aura() is not Burning) as Array[CellData]
		if cells.is_empty():
			break
		cells.pick_random().set_aura(Burning)
	
	clear_mana()
