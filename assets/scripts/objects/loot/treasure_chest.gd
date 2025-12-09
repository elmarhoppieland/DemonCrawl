@tool
extends Loot
class_name TreasureChest

# ==============================================================================
var tween: Tween
# ==============================================================================

func _get_name_id() -> String:
	return "object.treasure-chest"


func _get_texture() -> Texture2D:
	return get_theme_icon("default", "TreasureChest").duplicate()


func _collect() -> bool:
	if tween:
		return false
	
	const CHEST_OPEN_ANIM_DURATION := 0.2
	const CHEST_OPEN_WAIT_DURATION := 0.5
	
	const CHEST_ATLAS_WIDTH := 5
	const CHEST_ATLAS_MAX_X := (CHEST_ATLAS_WIDTH - 1) * Cell.CELL_SIZE.x
	
	tween = create_tween()
	
	tween.tween_method(func(value: float):
		get_texture().region.position.x = floorf(value / Cell.CELL_SIZE.x) * Cell.CELL_SIZE.x
	, 0.0, CHEST_ATLAS_MAX_X, CHEST_OPEN_ANIM_DURATION)
	
	tween.tween_interval(CHEST_OPEN_WAIT_DURATION)
	tween.tween_callback(ChestPopup.show_rewards.bind(self))
	tween.tween_callback(clear)
	
	return true


func _clear_on_collect() -> bool:
	return false


func _get_charitable_amount() -> int:
	return 5


func _can_interact() -> bool:
	return true


func get_coin_reward() -> int:
	var reward: int = randi_range(6, 2 * Quest.get_current().get_selected_stage().max_power + 6)
	return EffectManager.propagate_mutable((get_quest().get_event_bus(ChestEffects) as ChestEffects).get_coin_reward, 1, self, reward)


func get_item_reward_amount() -> int:
	return EffectManager.propagate_mutable((get_quest().get_event_bus(ChestEffects) as ChestEffects).get_item_reward_amount, 1, self, 1)


func get_item_reward_max_cost() -> int:
	return EffectManager.propagate_mutable((get_quest().get_event_bus(ChestEffects) as ChestEffects).get_item_reward_max_cost, 1, 
		self,
		4 * Quest.get_current().get_selected_stage().max_power + 3
	)


class ChestEffects extends EventBus:
	signal get_coin_reward(chest: TreasureChest, reward: int)
	
	signal get_item_reward_amount(chest: TreasureChest, amount: int)
	signal get_item_reward_max_cost(chest: TreasureChest, max_cost: int)
