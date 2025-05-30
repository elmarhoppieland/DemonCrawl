@tool
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
	Eternity.save()
	return true


func get_display_name() -> String:
	return _get_name()


func _get_name() -> String:
	return ""


func get_icon() -> Texture2D:
	return _get_icon()


func _get_icon() -> Texture2D:
	return null


func get_items() -> Array[TokenShopItemBase]:
	return _get_items()


func _get_items() -> Array[TokenShopItemBase]:
	return []
