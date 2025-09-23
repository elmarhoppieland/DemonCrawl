@tool
extends PassiveItem

# ==============================================================================
const BONES := preload("res://assets/items/bones.tres")
# ==============================================================================

func _activate() -> void:
	get_inventory().item_gain(BONES.create())
