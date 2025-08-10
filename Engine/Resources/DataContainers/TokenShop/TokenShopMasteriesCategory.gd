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
	
	Codex.tokens -= item.get_cost()
	
	var selectable := Codex.get_selectable_mastery(item.mastery)
	if selectable:
		selectable.level = item.mastery.level
	else:
		Codex.selectable_masteries.append(item.mastery.duplicate())
	
	return true


func _get_name() -> String:
	return name


func _get_icon() -> Texture2D:
	return icon


func _get_items() -> Array[TokenShopItemBase]:
	var items: Array[TokenShopItemBase] = []
	
	for mastery in DemonCrawl.get_full_registry().masteries:
		var item := MasteryItem.new()
		var data := Mastery.MasteryData.new()
		data.mastery = mastery
		data.level = Codex.get_selectable_mastery_level(mastery) + 1
		item.mastery = data
		
		items.append(item)
	
	return items


class MasteryItem extends TokenShopItemBase:
	@export var mastery: Mastery.MasteryData = null
	
	func _get_name() -> String:
		return mastery.create_temp().get_display_name()
	
	func _get_description() -> String:
		var unlock_text := mastery.create_temp().get_condition_text()
		var text := "• " + "\n• ".join(mastery.create_temp().get_description())
		if not unlock_text.is_empty() and not is_purchased():
			text += "\n\n(%s)" % unlock_text
		return text
	
	func _get_icon() -> Texture2D:
		return mastery.create_temp().create_icon()
	
	func _get_cost() -> int:
		return mastery.create_temp().get_cost()
	
	func _is_locked() -> bool:
		for condition in mastery.create_temp().get_conditions():
			if not condition.is_met():
				return true
		
		return false
	
	func _is_purchased() -> bool:
		return Codex.get_selectable_mastery_level(mastery) >= mastery.create().get_max_level()
