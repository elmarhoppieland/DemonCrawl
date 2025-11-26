extends WishpoolReward
class_name WishpoolDefenseReward

# ==============================================================================

func _perform():
	_wishpool.get_stats().defense += reward_per_charge * _wishpool.charges
