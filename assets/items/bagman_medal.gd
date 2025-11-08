@tool
extends OmenItem

# ==============================================================================

func _get_guaranteed_objects(input: Array[CellObject]) -> Array[CellObject]:
	input.append(Bagman.new())
	return input
