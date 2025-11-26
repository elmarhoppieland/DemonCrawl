extends WishpoolReward
class_name WishpoolManaReward

# ==============================================================================

func _perform():
	_wishpool.get_inventory().mana_gain(reward_per_charge * _wishpool.charges, self)
