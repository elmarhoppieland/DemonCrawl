@tool
extends ConsumableItem

# ==============================================================================

func _use() -> void:
	get_quest().get_inventory().mana_gain(100, self)
