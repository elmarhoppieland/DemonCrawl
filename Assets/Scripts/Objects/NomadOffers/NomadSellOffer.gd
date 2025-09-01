extends NomadOffer
class_name NomadSellOffer

# ==============================================================================
@export var cost := -1
# ==============================================================================

func _can_afford() -> bool:
	return Quest.get_current().get_stats().coins >= cost


func _pay() -> void:
	Quest.get_current().get_stats().spend_coins(cost, _nomad)


func _perform() -> void:
	cost += 1


func _get_fail_message() -> String:
	return tr("stranger.nomad.sell.fail")


func get_description() -> String:
	return "\"" + _get_description() + "\"\n" + tr("stranger.nomad.price").format({
		"cost": cost
	})
