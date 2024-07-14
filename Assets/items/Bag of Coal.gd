extends Item

# ==============================================================================

func change_morality(morality: int) -> void:
	if morality >= PlayerStats.morality:
		return
	if not is_charged():
		return
	
	Inventory.gain_item(Item.from_path("res://Assets/items/Coal"))
	
	for coal in Inventory.items.filter(func(item: Item) -> bool: return item.data == ItemData.from_path("res://Assets/items/Coal")):
		var cells := Board.get_cells().filter(func(cell: Cell) -> bool: return cell.aura != "burning")
		cells[RNG.randi() % cells.size()].aura = "burning"
	
	clear_mana()
