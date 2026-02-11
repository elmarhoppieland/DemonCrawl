extends Glint

# ==============================================================================
const HEALTH_POTION := preload("res://assets/items/health_potion.tres")
const MANA_POTION := preload("res://assets/items/mana_potion.tres")
# ==============================================================================

func _quest_start() -> void:
	get_quest().get_inventory().item_gain(HEALTH_POTION.create())
	get_quest().get_inventory().item_gain(MANA_POTION.create())
