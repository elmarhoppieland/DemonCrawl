@tool
extends Stranger
class_name Priest

# ==============================================================================
@export var cost := -1
# ==============================================================================

func _spawn() -> void:
	cost = randi_range(15, 30)


func _interact() -> void:
	if Quest.get_current().get_stats().coins < cost:
		Toasts.add_toast(tr("STRANGER_PRIEST_FAIL"), get_source())
		return
	
	Quest.get_current().get_stats().spend_coins(cost, self)
	
	activate()


func _activate() -> void:
	var omens: Array[Item] = []
	omens.assign(get_quest().get_inventory().items.filter(func(item: Item) -> bool: return item.get_type() == Item.Type.OMEN))
	if not omens.is_empty():
		Quest.get_current().get_inventory().item_lose(omens.pick_random())
	
	if Quest.get_current().get_attributes().morality < 0:
		Quest.get_current().get_attributes().morality = 0


func _get_annotation_title() -> String:
	return tr("STRANGER_PRIEST").to_upper()


func _get_annotation_subtext() -> String:
	return "\"" + tr("STRANGER_PRIEST_DESCRIPTION").format({
		"cost": cost
	}) + "\""


func _can_afford() -> bool:
	return Quest.get_current().get_stats().coins >= cost
