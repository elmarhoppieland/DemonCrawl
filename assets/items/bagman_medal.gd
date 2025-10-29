@tool
extends OmenItem

# ==============================================================================

func get_guaranteed_objects(input: Array[CellObject]) -> Array[CellObject]:
	input.append(Bagman.new())
	return input
