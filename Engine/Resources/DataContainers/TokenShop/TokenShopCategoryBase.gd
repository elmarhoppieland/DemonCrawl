@tool
@abstract
extends Resource
class_name TokenShopCategoryBase

# ==============================================================================

func try_purchase(item: TokenShopItemBase) -> bool:
	return _try_purchase(item)


func _try_purchase(item: TokenShopItemBase) -> bool:
	if Codex.tokens < item.get_cost():
		return false
	
	Codex.tokens -= item.get_cost()
	TokenShop.purchase(item)
	return true


func get_display_name() -> String:
	return _get_name()


## Virtual method. Should return this category's name.
@abstract func _get_name() -> String


func get_icon() -> Texture2D:
	return _get_icon()


## Virtual method. Should return this category's icon.
@abstract func _get_icon() -> Texture2D


func get_items() -> Array[TokenShopItemBase]:
	return _get_items()


## Virtual method. Should return this category's items.
@abstract func _get_items() -> Array[TokenShopItemBase]
