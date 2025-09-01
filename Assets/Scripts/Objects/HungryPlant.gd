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
		Toasts.add_toast(tr("stranger.plant.fail"), get_source())
		return
	
	activate()


func _activate() -> void:
	get_quest().get_inventory().get_random_item().clear()
	current += 1
	if current >= maximum:
		current = 0
		maximum *= 2
		
		match type:
			RewardType.COINS:
				get_quest().get_stats().coins += reward_amount
			RewardType.SOULS:
				get_quest().get_stats().gain_souls(reward_amount, self)
			RewardType.MANA:
				get_quest().get_inventory().mana_gain(reward_amount, self)
			RewardType.PRESENT:
				const PRESENT := preload("res://Assets/Items/Present.tres")
				get_quest().get_inventory().item_gain(PRESENT.create())


func _get_annotation_title() -> String:
	return tr("stranger.plant").to_upper()


func _get_annotation_subtext() -> String:
	return "\"" + tr("stranger.plant.description") + "\"\n" + tr("stranger.plant.reward").format({
		"v": current,
		"max": maximum,
		"reward": tr_n("stranger.plant.reward." + RewardType.find_key(type).to_lower(), "stranger.plant.reward." + RewardType.find_key(type).to_lower() + ".plural", reward_amount).format({
			"amount": reward_amount
		})
	})


func _can_afford() -> bool:
	return not Quest.get_current().get_inventory().items.is_empty()
