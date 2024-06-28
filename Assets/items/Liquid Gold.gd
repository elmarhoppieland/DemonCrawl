extends Item

# ==============================================================================

func spend_coins(amount: int, _dest: Object) -> void:
	var item_data: ItemData
	while true:
		var items := ItemDB.get_items_data().filter(func(a: ItemData): return a.cost == amount)
		if items.is_empty():
			amount -= 1
			continue
		
		item_data = items[RNG.randi() % items.size()]
		break
	
	transform(item_data.get_item_script().new())
