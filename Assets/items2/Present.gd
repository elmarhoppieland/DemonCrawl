@tool
extends Item

# ==============================================================================

func _use() -> void:
	transform(get_quest().get_item_pool().create_filter().disallow_type(Type.OMEN).get_random_item().create())
