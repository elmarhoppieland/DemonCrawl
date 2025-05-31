@tool
extends TokenShopCategoryBase
class_name TokenShopCategory

# ==============================================================================
@export var name := ""
@export var icon: Texture2D = null
@export var items: Array[TokenShopItemBase] = []
# ==============================================================================

func _try_purchase(item: TokenShopItemBase) -> bool:
	if Codex.tokens < item.get_cost():
		return false
	
	Codex.tokens -= item.get_cost()
	TokenShop.purchase(item)
	Eternity.save()
	return true


func _get_name() -> String:
	return name


func _get_icon() -> Texture2D:
	return icon


func _get_items() -> Array[TokenShopItemBase]:
	return items
