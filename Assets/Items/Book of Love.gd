@tool
extends Book

# ==============================================================================

func _activate() -> void:
	get_stats().gain_souls(1, self)
