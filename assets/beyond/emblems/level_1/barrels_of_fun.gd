extends Emblem

# TODO: actually do what is should do (this requires Powder Keg and therefore Barrels)

# ==============================================================================
const APPLE := preload("res://assets/items/apple.tres")
# ==============================================================================

func _quest_start() -> void:
	for i in 3:
		get_quest().get_inventory().item_gain(APPLE.create())
