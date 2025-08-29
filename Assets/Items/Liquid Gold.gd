@tool
extends Item

# ==============================================================================

func spend_coins(amount: int, _dest: Object) -> void:
	while true:
		var filter := get_quest().get_item_pool().create_filter().set_cost(amount).disallow_type(Type.OMEN)
		if filter.is_empty():
			amount -= 1
			continue
		
		transform(filter.get_random_item().create())
		return
