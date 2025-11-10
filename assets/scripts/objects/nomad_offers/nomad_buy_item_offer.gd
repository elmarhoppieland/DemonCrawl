extends NomadOffer
class_name NomadBuyItemOffer

# ==============================================================================
@export var item: ItemData
@export var price := 0
# ==============================================================================

func _spawn() -> void:
	item = _nomad.get_quest().get_inventory().get_random_item().data
	price = maxi(1, roundi(randf_range(0.8, 1.2) * item.cost))


func _perform() -> void:
	for i in _nomad.get_quest().get_inventory().get_items():
		if i.data == item:
			_nomad.get_quest().get_inventory().item_lose(i)
			_nomad.get_quest().get_stats().coins += price
			return
	
	Debug.log_error("NomadBuyItemOffer failed, but _can_perform() returned true.")


func _can_afford() -> bool:
	return true


func _can_perform() -> bool:
	for i in Quest.get_current().get_inventory().get_item_count():
		if Quest.get_current().get_inventory().get_item(i).get_script() == item.get_script():
			return true
	
	return false


func _get_fail_message() -> String:
	return tr("stranger.nomad.buy.item.fail").format({
		"item": tr(item.name)
	})


func _get_description() -> String:
	return "\"" + tr("stranger.nomad.buy.item").format({
		"item": tr(item.name)
	}) + "\"\n" + tr("stranger.nomad.price").format({
		"cost": price
	})


static func _is_enabled() -> bool:
	return Quest.get_current().get_inventory().get_item_count() > 0
