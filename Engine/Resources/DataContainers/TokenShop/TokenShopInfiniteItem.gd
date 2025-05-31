@tool
extends TokenShopItem
class_name TokenShopInfiniteItem

# ==============================================================================

func _is_purchased() -> bool:
	return false


func _reapply_reward(purchase_count: int) -> void:
	if reward:
		for i in purchase_count:
			reward.reapply()
