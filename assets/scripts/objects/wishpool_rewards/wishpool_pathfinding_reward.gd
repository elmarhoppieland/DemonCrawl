@tool
extends WishpoolReward
class_name WishpoolPathfindingReward

# ==============================================================================

func _perform():
	_wishpool.get_attributes().pathfinding += reward_per_charge * _wishpool.charges
