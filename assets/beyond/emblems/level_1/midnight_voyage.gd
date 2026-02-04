extends Emblem

# ==============================================================================
const LANTERN := preload("res://assets/items/lantern.tres")
# ==============================================================================

# TODO: add Dark mod to all stages

func _quest_start() -> void:
	get_quest().get_inventory().item_gain(LANTERN.create())
