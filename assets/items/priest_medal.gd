@tool
extends PassiveItem

# ==============================================================================

func _get_guaranteed_objects(input: Array[CellObject]) -> Array[CellObject]:
	input.append(Priest.new())
	return input
