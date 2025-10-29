@tool
extends PassiveItem

# ==============================================================================

func get_guaranteed_objects(input: Array[CellObject]) -> Array[CellObject]:
	input.append(Nomad.new())
	return input
