@tool
extends Stranger
class_name Mage

# ==============================================================================
const COST_MIN := 5
const COST_MAX := 15
const MANA_MODIFIER_MIN := 0.05
const MANA_MODIFIER_MAX := 0.15
# ==============================================================================
@export var cost := -1
# ==============================================================================

func _spawn() -> void:
	cost = randi_range(COST_MIN, COST_MAX)
	var item := get_quest().get_item_pool().create_filter().filter_tag("_targeted").disallow_all_types().allow_type(MagicItem).set_allow_items_in_inventory().get_random_item().create()
	item.add_override("mana", item.get_max_mana() * randf_range(MANA_MODIFIER_MIN, MANA_MODIFIER_MAX))
	item.charge()
	add_child(item)
	
	item.cleared.connect(func() -> void:
		Toasts.add_toast(tr("stranger.mage.lost-item").format({
			"item": tr(item.get_item_name())
		}), get_source())
		item.set_mana(-1)
	)


func _interact() -> void:
	if not get_item().is_charged():
		return
	if Quest.get_current().get_stats().coins < cost:
		Toasts.add_toast(tr("stranger.mage.fail"), get_source())
		return
	
	Quest.get_current().get_stats().spend_coins(cost, self)
	
	activate()


func _activate() -> void:
	if get_item().get_mana() < 0:
		return
	
	get_item().invoke()
	get_item().clear_mana()


func get_item() -> Item:
	for child in get_children():
		if child is Item:
			return child
	return null


func _get_annotation_title() -> String:
	return tr("stranger.mage").to_upper()


func _get_annotation_subtext() -> String:
	if get_item().get_mana() < 0:
		return "\"" + tr("stranger.mage.description.no-item").format({
			"item": tr(get_item().get_item_name())
		}) + "\""
	
	if get_item().is_charged():
		return "\"" + tr("stranger.mage.description").format({
			"item": tr(get_item().get_item_name()),
			"cost": cost
		}) + "\""
	
	return "\"" + tr("stranger.mage.description.charging").format({
		"item": tr(get_item().get_item_name()),
		"mana": get_item().get_max_mana() - get_item().get_mana()
	}) + "\""


func _has_annotation_text() -> bool:
	return get_item() != null


func _can_afford() -> bool:
	return get_stats().coins >= cost
