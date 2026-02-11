@tool
extends ConsumableItem

# ==============================================================================

func _use() -> void:
	get_stats().life_restore(3, self)
