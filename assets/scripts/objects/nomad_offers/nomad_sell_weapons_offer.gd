extends NomadSellOffer
class_name NomadSellWeaponsOffer

# ==============================================================================

func _spawn() -> void:
	cost = randi_range(12, 20)


func _perform() -> void:
	super()
	
	var item := _nomad.get_quest().get_item_pool().create_filter().filter_tag("weapon").set_min_cost(1).get_random_item()
	Quest.get_current().get_inventory().item_gain(item.create())
