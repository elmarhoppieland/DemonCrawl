@tool
extends ConsumableItem

# ==============================================================================

func _use() -> void:
	life_restore(1)
