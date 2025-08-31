@tool
extends Book

# ==============================================================================
const PATHFINDING_GAIN_AMOUNT := 1
# ==============================================================================

func _activate() -> void:
	get_attributes().pathfinding += PATHFINDING_GAIN_AMOUNT
