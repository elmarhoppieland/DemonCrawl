extends NomadSellOffer
class_name NomadSellMagicOffer

# ==============================================================================

func _spawn() -> void:
	cost = randi_range(12, 25)


func _perform() -> void:
	super()
	
	var item := ItemDB.create_filter(_nomad.get_inventory()).disallow_all_types().allow_type(Item.Type.MAGIC).get_random_item()
	_nomad.get_inventory().item_gain(item.create())
