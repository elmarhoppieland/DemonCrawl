extends WishpoolReward
class_name WishpoolLifeReward

# ==============================================================================

func _perform():
	_wishpool.life_restore(reward_per_charge * _wishpool.charges)
