@tool
extends Landmark
class_name Wishpool

# ==============================================================================

var reward: WishpoolReward
var charges: int = 1
var charge_cell_count: int = 0

# ==============================================================================

func _get_texture() -> Texture2D:
	return Texture2D.new()


func _can_interact() -> bool:
	return true


func get_stats() -> QuestStats:
	return get_quest().get_stats()


func get_inventory() -> QuestInventory:
	return get_quest().get_inventory()

class WishPoolEffects extends EventBus:
	signal get_heal_amount(amount: int)
	signal get_coin_value(value: int)
	signal get_mana_value(value: int)
	signal get_minion_count(value: int)
	signal get_pathfinding_value(value: int)
