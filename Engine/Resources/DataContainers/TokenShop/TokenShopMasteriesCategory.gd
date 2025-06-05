@tool
extends TokenShopCategoryBase
class_name TokenShopMasteriesCategory

# ==============================================================================
@export var name := ""
@export var icon: Texture2D = null
@export var masteries: Array[Mastery] = []
# ==============================================================================

func _try_purchase(item: TokenShopItemBase) -> bool:
	if not item is MasteryItem:
		return super(item)
	if Codex.tokens < item.get_cost():
		return false
	
	Codex.tokens -= item.get_cost()
	
	for mastery in Codex.selectable_masteries:
		if mastery.get_script() == item.mastery.get_script() and mastery.level < item.mastery.level:
			mastery.level = item.mastery.level
			item.mastery = item.mastery.duplicate()
			item.mastery.level += 1
			Eternity.save()
			return true
	
	Codex.selectable_masteries.append(item.mastery)
	item.mastery = item.mastery.duplicate()
	item.mastery.level += 1
	return true


func _get_name() -> String:
	return name


func _get_icon() -> Texture2D:
	return icon


func _get_items() -> Array[TokenShopItemBase]:
	var items: Array[TokenShopItemBase] = []
	
	for mastery in Codex.masteries:
		var item := MasteryItem.new()
		item.mastery = mastery.duplicate()
		item.mastery.level = Codex.get_selectable_mastery_level(mastery) + 1
		
		items.append(item)
	
	return items


class MasteryItem extends TokenShopItemBase:
	@export var mastery: Mastery = null
	
	func _get_name() -> String:
		return mastery.get_display_name()
	
	func _get_description() -> String:
		var unlock_text := mastery.get_condition_text()
		var text := "• " + "\n• ".join(mastery.get_description())
		if not unlock_text.is_empty() and not is_purchased():
			text += "\n\n(%s)" % unlock_text
		return text
	
	func _get_icon() -> Texture2D:
		return mastery.create_icon()
	
	func _get_cost() -> int:
		return mastery.get_cost()
	
	func _is_locked() -> bool:
		for condition in mastery.get_conditions():
			if not condition.is_met():
				return true
		
		return false
	
	func _is_purchased() -> bool:
		return Codex.get_selectable_mastery_level(mastery) >= mastery.get_max_level()
