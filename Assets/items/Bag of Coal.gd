@tool
extends Item

# ==============================================================================

func change_morality(morality: int) -> void:
	if morality >= Quest.get_current().get_instance().morality:
		return
	if not is_charged():
		return
	
	gain_item(Item.from_path("res://Assets/items/Coal"))
	
	for coal in get_items().filter(func(item: Item) -> bool: return item.data == ItemData.from_path("res://Assets/items/Coal")):
		var cells := Stage.get_current().get_instance().get_cells().filter(func(cell: CellData) -> bool: return cell.get_aura() != "burning")
		cells[randi() % cells.size()].aura = "burning"
	
	clear_mana()
