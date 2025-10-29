@tool
extends PassiveItem

# ==============================================================================

func get_guaranteed_objects(input: Array[CellObject]) -> Array[CellObject]:
	input.append(Mage.new())
	return input
