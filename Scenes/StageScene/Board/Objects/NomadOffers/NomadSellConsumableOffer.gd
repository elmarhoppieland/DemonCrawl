extends NomadSellOffer
class_name NomadSellConsumableOffer

# ==============================================================================
@export var item: Item
# ==============================================================================

func _spawn() -> void:
	item = ItemDB.create_filter()\
		.disallow_all_types()\
		.allow_type(Item.Type.CONSUMABLE)\
		.set_min_cost(1)\
		.get_random_item()
	
	cost = roundi(randf_range(0.8, 1.2) * item.get_cost())


func _perform() -> void:
	super()
	
	Quest.get_current().get_inventory().item_gain(item.duplicate())
