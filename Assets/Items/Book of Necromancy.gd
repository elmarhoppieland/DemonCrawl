@tool
extends PassiveItem

# ==============================================================================
const BONES := preload("res://Assets/Items/Bones.tres")
# ==============================================================================

func _activate() -> void:
	get_inventory().item_gain(BONES.create())
