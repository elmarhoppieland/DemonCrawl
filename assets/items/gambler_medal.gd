@tool
extends PassiveItem

# ==============================================================================

func get_guaranteed_objects(input: Array[CellObject]) -> Array[CellObject]:
	input.append(Gambler.new())
	return input
