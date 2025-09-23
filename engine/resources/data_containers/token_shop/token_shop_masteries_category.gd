@tool
extends TokenShopCategoryBase
class_name TokenShopMasteriesCategory

# ==============================================================================
@export var name := ""
@export var icon: Texture2D = null
# ==============================================================================

func _try_purchase(item: TokenShopItemBase) -> bool:
	if item is not MasteryItem:
		return super(item)
	if Codex.tokens < item.get_cost():
		return false
	
	item.purchase()
	
	return true


func _get_name() -> String:
	return name


func _get_icon() -> Texture2D:
	return icon


func _get_items() -> Array[TokenShopItemBase]:
	var items: Array[TokenShopItemBase] = []
	
	for data in DemonCrawl.get_full_registry().masteries:
		var item := MasteryItem.new()
		item.mastery = data.instantiate(clampi(Codex.get_selectable_mastery_level(data) + 1, 1, data.get_max_level()))
		items.append(item)
	
	return items


class MasteryItem extends TokenShopItemBase:
	@export var mastery: MasteryInstanceData = null
	
	func _purchase() -> void:
		Codex.tokens -= get_cost()
		
		var selectable := Codex.get_selectable_mastery(mastery)
		if selectable:
			selectable.level = mastery.level
		else:
			Codex.selectable_masteries.append(mastery.duplicate())
	
	func _get_name() -> String:
		return mastery.get_name_text()
	
	func _get_description() -> String:
		return mastery.get_description_text(not is_purchased())
	
	func _get_icon() -> Texture2D:
		return mastery.get_icon()
	
	func _get_cost() -> int:
		return mastery.get_cost()
	
	func _is_locked() -> bool:
		return Codex.get_unlocked_mastery_level(mastery) < mastery.level
	
	func _is_purchased() -> bool:
		return Codex.get_selectable_mastery_level(mastery) >= mastery.get_max_level()
