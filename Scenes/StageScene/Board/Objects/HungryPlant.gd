@tool
extends Stranger
class_name HungryPlant

# ==============================================================================
enum RewardType {
	COINS,
	SOULS,
	MANA,
	PRESENT
}
# ==============================================================================
@export var type := RewardType.COINS
@export var reward_amount := -1
@export var current := 0
@export var maximum := -1
# ==============================================================================

func _spawn() -> void:
	type = RewardType.values().pick_random()
	maximum = randi_range(3, 6)
	
	match type:
		RewardType.COINS:
			reward_amount = randi_range(5, 12)
		RewardType.SOULS:
			reward_amount = randi_range(1, 3)
		RewardType.MANA:
			reward_amount = randi_range(50, 200)
		RewardType.PRESENT:
			reward_amount = 1


func _interact() -> void:
	if Quest.get_current().get_inventory().is_empty():
		Toasts.add_toast(tr("STRANGER_PLANT_FAIL"), get_source())
		return
	
	activate()


func _activate() -> void:
	Quest.get_current().get_inventory().item_lose_random()
	current += 1
	if current >= maximum:
		current = 0
		maximum *= 2
		
		match type:
			RewardType.COINS:
				Quest.get_current().get_stats().coins += reward_amount
			RewardType.SOULS:
				Quest.get_current().get_stats().gain_souls(reward_amount, self)
			RewardType.MANA:
				Quest.get_current().get_inventory().mana_gain(reward_amount, self)
			RewardType.PRESENT:
				const PRESENT = preload("res://Assets/items/Present.tres")
				Quest.get_current().get_inventory().item_gain(PRESENT.duplicate())
	
	Toasts.add_toast(tr("STRANGER_PLANT_USE"), get_source())


func _get_annotation_title() -> String:
	return tr("STRANGER_PLANT").to_upper()


func _get_annotation_subtext() -> String:
	return "\"" + tr("STRANGER_PLANT_DESCRIPTION") + "\"\n" + tr("STRANGER_PLANT_REWARD").format({
		"v": current,
		"max": maximum,
		"reward": tr_n("STRANGER_PLANT_REWARD_" + RewardType.find_key(type), "STRANGER_PLANT_REWARD_" + RewardType.find_key(type) + "_PLURAL", reward_amount).format({
			"amount": reward_amount
		})
	})
