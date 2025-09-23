@tool
extends ConsumableItem

# ==============================================================================

func _use() -> void:
	transform(get_quest().get_item_pool().create_filter().disallow_type(OmenItem).get_random_item().create())
