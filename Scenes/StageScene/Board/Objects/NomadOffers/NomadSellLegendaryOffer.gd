extends NomadSellOffer
class_name NomadSellLegendaryOffer

# ==============================================================================

func _spawn() -> void:
	cost = randi_range(20, 40)


func _perform() -> void:
	super()
	
	var item := ItemDB.create_filter().disallow_all_types().allow_type(Item.Type.LEGENDARY).get_random_item()
	Quest.get_current().get_inventory().item_gain(item)
