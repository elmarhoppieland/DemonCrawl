@tool
extends WishpoolReward
class_name WishpoolLifeReward

# ==============================================================================

func _perform():
	_wishpool.get_stats().life_restore(reward_per_charge * _wishpool.charges, self)
