@tool
extends Book

# ==============================================================================

func _activate() -> void:
	get_attributes().powerchording += 1
