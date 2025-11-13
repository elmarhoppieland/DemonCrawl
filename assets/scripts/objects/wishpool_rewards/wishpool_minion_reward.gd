@tool
extends WishpoolReward
class_name WishpoolMinionReward

# ==============================================================================

func _perform():
	for _i in range(reward_per_charge * _wishpool.charges):
		var minion
