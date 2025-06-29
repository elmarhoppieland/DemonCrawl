@tool
extends Item

# ==============================================================================
const COAL := preload("res://Assets/Items/Coal.tres")
# ==============================================================================

func change_morality(morality: int) -> void:
	if morality >= Quest.get_current().get_attributes().morality:
		return
	if not is_charged():
		return
	
	gain_item(COAL)
	
	for item in get_items():
		if item.get_script() != COAL.get_script():
			continue
		var cells := StageInstance.get_current().get_cells().filter(func(cell: CellData) -> bool: return cell.get_aura() != "burning") as Array[CellData]
		if cells.is_empty():
			break
		cells[randi() % cells.size()].aura = Burning.new()
	
	clear_mana()


func _can_use() -> bool:
	return false
