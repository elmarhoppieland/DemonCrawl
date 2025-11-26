extends WishpoolReward
class_name WishpoolMinionReward

# ==============================================================================
const MINION = preload("res://assets/items/minion.tres")
# ==============================================================================

func _perform():
	for _i in range(reward_per_charge * _wishpool.charges):
		_wishpool.get_inventory().item_gain(MINION.create())
