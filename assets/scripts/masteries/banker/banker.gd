@tool
extends Mastery
class_name Banker

# ==============================================================================

func _enable() -> void:
	(get_quest().get_event_bus(TreasureChest.ChestEffects) as TreasureChest.ChestEffects).get_coin_reward.connect(_get_coin_reward)


func _disable() -> void:
	(get_quest().get_event_bus(TreasureChest.ChestEffects) as TreasureChest.ChestEffects).get_coin_reward.disconnect(_get_coin_reward)


func _quest_start() -> void:
	get_stats().coins += 15


func _get_coin_reward(_chest: TreasureChest, reward: int) -> int:
	if level < 2:
		return reward
	return 2 * reward


func _ability() -> void:
	get_stats().coins *= 2
