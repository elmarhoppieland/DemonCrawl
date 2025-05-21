@tool
extends Stranger
class_name Mage

# ==============================================================================
@export var cost := -1
@export var item: Item
@export var item_lost := false
# ==============================================================================

func _spawn() -> void:
	const COST_MIN := 5
	const COST_MAX := 15
	const MANA_MODIFIER_MIN := 0.05
	const MANA_MODIFIER_MAX := 0.15
	
	cost = randi_range(COST_MIN, COST_MAX)
	item = ItemDB.create_filter().filter_tag("_targeted").disallow_all_types().allow_type(Item.Type.MAGIC).get_random_item()
	item.set_max_mana(int(item.get_max_mana() * randf_range(MANA_MODIFIER_MIN, MANA_MODIFIER_MAX)))
	item.charge()
	
	item.cleared.connect(func() -> void:
		Toasts.add_toast(tr("STRANGER_MAGE_LOST_ITEM").format({
			"item": tr(item.get_name())
		}), get_source())
		item_lost = true
	)


func _interact() -> void:
	if item_lost:
		return
	if not item.is_charged():
		return
	if Quest.get_current().get_stats().coins < cost:
		Toasts.add_toast(tr("STRANGER_MAGE_FAIL"), get_source())
		return
	
	Quest.get_current().get_stats().spend_coins(cost, self)
	
	activate()


func _activate() -> void:
	item.invoke()


func _get_annotation_title() -> String:
	return tr("STRANGER_MAGE").to_upper()


func _get_annotation_subtext() -> String:
	if item_lost:
		return "\"" + tr("STRANGER_MAGE_NO_ITEM").format({
			"item": tr(item.get_name())
		}) + "\""
	
	if item.is_charged():
		return "\"" + tr("STRANGER_MAGE_DESCRIPTION").format({
			"item": tr(item.get_name()),
			"cost": cost
		}) + "\""
	
	return "\"" + tr("STRANGER_MAGE_CHARGING").format({
		"item": tr(item.get_name()),
		"mana": item.get_max_mana() - item.get_mana()
	}) + "\""


func _has_annotation_text() -> bool:
	return item != null
