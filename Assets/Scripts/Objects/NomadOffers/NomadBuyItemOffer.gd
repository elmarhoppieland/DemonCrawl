extends NomadOffer
class_name NomadBuyItemOffer

# ==============================================================================
@export var item: Item
@export var price := 0
# ==============================================================================

func _spawn() -> void:
	item = Quest.get_current().get_inventory().get_item(randi() % Quest.get_current().get_inventory().get_item_count())
	price = maxi(1, roundi(randf_range(0.8, 1.2) * item.get_cost()))


func _can_perform(_free: bool = false) -> bool:
	for i in Quest.get_current().get_inventory().get_item_count():
		if Quest.get_current().get_inventory().get_item(i).get_script() == item.get_script():
			return true
	
	return false


func _get_fail_message() -> String:
	return tr("STRANGER_NOMAD_MISSING_ITEM").format({
		"item": tr(item.get_name())
	})


func _get_description() -> String:
	return "\"" + tr("STRANGER_NOMAD_BUY_ITEM").format({
		"item": tr(item.get_name())
	}) + "\"\n" + tr("STRANGER_NOMAD_PRICE").format({
		"cost": price
	})


static func _is_enabled() -> bool:
	return Quest.get_current().get_inventory().get_item_count() > 0
