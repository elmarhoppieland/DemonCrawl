@tool
extends Resource
class_name TokenShopItemBase

# ==============================================================================

func notify_purchased() -> void:
	_purchase()


func _purchase() -> void:
	pass


func reapply_reward(purchase_count: int) -> void:
	_reapply_reward(purchase_count)


@warning_ignore("unused_parameter")
func _reapply_reward(purchase_count: int) -> void:
	pass


func is_purchased() -> bool:
	return _is_purchased()


func _is_purchased() -> bool:
	return TokenShop.is_item_purchased(self)


func get_display_name() -> String:
	return _get_name()


func _get_name() -> String:
	return ""


func get_description() -> String:
	return _get_description()


func _get_description() -> String:
	return ""


func get_icon() -> Texture2D:
	return _get_icon()


func _get_icon() -> Texture2D:
	return null


func get_cost() -> int:
	return _get_cost()


func _get_cost() -> int:
	return 0


func get_reward_flag() -> String:
	return _get_reward_flag()


func _get_reward_flag() -> String:
	return ""


func is_visible() -> bool:
	return _is_visible()


func _is_visible() -> bool:
	return true


func is_locked() -> bool:
	return _is_locked()


func _is_locked() -> bool:
	return false
