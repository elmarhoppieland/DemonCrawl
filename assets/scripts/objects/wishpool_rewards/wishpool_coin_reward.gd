extends WishpoolReward
class_name WishpoolCoinReward

# ==============================================================================

func _perform():
	_wishpool.get_stats().gain_coins(reward_per_charge * _wishpool.charges, self)
