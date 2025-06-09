@tool
extends Mastery
class_name Banker

# ==============================================================================

func _quest_load() -> void:
	Effects.MutableSignals.get_chest_coins.connect(_get_chest_coins)


func _quest_unload() -> void:
	Effects.MutableSignals.get_chest_coins.disconnect(_get_chest_coins)


func _quest_start() -> void:
	get_stats().coins += 15


func _get_chest_coins(coins: int, _chest: TreasureChest) -> int:
	if level < 2:
		return coins
	return 2 * coins


func _ability() -> void:
	get_stats().coins *= 2


func _get_max_charges() -> int:
	return 5
