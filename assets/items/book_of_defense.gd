@tool
extends Book

# ==============================================================================

func _activate() -> void:
	get_stats().defense += 1
