extends Glint

# ==============================================================================
const PRESENT := preload("res://assets/items/present.tres")
# ==============================================================================

func _quest_start() -> void:
	get_quest().get_inventory().item_gain(PRESENT.create())
