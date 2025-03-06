extends NomadOffer
class_name NomadSellOffer

# ==============================================================================
@export var cost := -1
# ==============================================================================

func _can_perform() -> bool:
	return Quest.get_current().get_stats().coins >= cost


func _perform() -> void:
	Quest.get_current().get_stats().spend_coins(cost, self) # TODO: maybe have the destination be the Nomad?
	cost += 1


func _get_fail_message() -> String:
	return tr("STRANGER_NOMAD_TOO_EXPENSIVE")


func get_description() -> String:
	return "\"" + _get_description() + "\"\n" + tr("STRANGER_NOMAD_PRICE").format({
		"cost": cost
	})
