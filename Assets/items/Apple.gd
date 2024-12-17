@tool
extends Item

# ==============================================================================

func _use() -> void:
	life_restore(1)
	clear()
