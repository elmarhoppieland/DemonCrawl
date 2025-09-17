@tool
@abstract
extends Resource
class_name TokenShopItemBase

# ==============================================================================

func notify_purchased() -> void:
	_purchase()


## Virtual method. Called when this item is purchased.
## [br][br][b]Note:[/b] This method is only called once when it is purchased.
## If this item needs to reapply its reward each time the profile
## is loaded, override [method _reapply_reward].
@abstract func _purchase() -> void


func reapply_reward(purchase_count: int) -> void:
	_reapply_reward(purchase_count)


## Virtual method. Called when the player loads a profile that has this item purchased.
## Should reapply its at level [param purchase_count].
@warning_ignore("unused_parameter")
func _reapply_reward(purchase_count: int) -> void:
	pass


func is_purchased() -> bool:
	return _is_purchased()


func _is_purchased() -> bool:
	return load("res://Engine/Scenes/TokenShop/TokenShop.gd").is_item_purchased(self)


func get_display_name() -> String:
	return _get_name()


## Virtual method. Should return this item's name.
@abstract func _get_name() -> String


func get_description() -> String:
	return _get_description()


## Virtual method. Should return this item's description.
@abstract func _get_description() -> String


func get_icon() -> Texture2D:
	return _get_icon()


## Virtual method. Should return this item's icon.
@abstract func _get_icon() -> Texture2D


func get_cost() -> int:
	return _get_cost()


## Virtual method. Should return this item's cost.
@abstract func _get_cost() -> int


func is_visible() -> bool:
	return _is_visible()


func _is_visible() -> bool:
	return true


func is_locked() -> bool:
	return _is_locked()


func _is_locked() -> bool:
	return false
