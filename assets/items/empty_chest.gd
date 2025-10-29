@tool
extends OmenItem

# ==============================================================================

# TODO: Does this item affect Beyond's 2nd Chest?
func get_guaranteed_objects(input: Array[CellObject]) -> Array[CellObject]:
	var index = -1
	for i in range(len(input)):
		if input[i] is TreasureChest:
			index = i
			break
	if index > 0:
		input.remove_at(index)
	return input
