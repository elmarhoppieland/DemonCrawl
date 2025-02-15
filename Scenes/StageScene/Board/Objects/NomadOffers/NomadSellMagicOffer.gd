extends NomadSellOffer
class_name NomadSellMagicOffer

# ==============================================================================

func _spawn() -> void:
	cost = randi_range(12, 25)


func _perform() -> void:
	super()
	
	var item := ItemDB.create_filter().disallow_all_types().allow_type(Item.Type.MAGIC).get_random_item()
	Quest.get_current().get_inventory().item_gain(item)
