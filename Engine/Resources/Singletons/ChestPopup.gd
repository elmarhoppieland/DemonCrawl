@abstract
class_name ChestPopup

# ==============================================================================
const COINS_SCENE := "res://Engine/Resources/Singletons/ChestCoinsPopup.tscn"
const ITEMS_SCENE := "res://Engine/Resources/Singletons/ChestItemsPopup.tscn"
# ==============================================================================

static func show_rewards(chest: TreasureChest) -> void:
	var quest := chest.get_quest()
	
	if randi() % 2:
		var instance: ChestCoinsPopup = load(COINS_SCENE).instantiate()
		var coins := chest.get_coin_reward()
		instance.coins = coins
		await DCPopup.popup_show_instance(instance)
		quest.get_stats().coins += coins
		instance.queue_free()
	else:
		var item_count := chest.get_item_reward_amount()
		var max_cost := chest.get_item_reward_max_cost()
		
		var rewards: Array[Collectible] = []
		for i in item_count:
			if randi() % 9:
				rewards.append(quest.get_item_pool().create_filter().disallow_type(OmenItem).set_min_cost(1).set_max_cost(max_cost).get_random_item().create())
			else:
				rewards.append(quest.get_item_pool().create_filter().disallow_all_types().allow_type(OmenItem).get_random_item().create())
		
		var instance: ChestItemsPopup = load(ITEMS_SCENE).instantiate()
		instance.rewards = rewards
		await DCPopup.popup_show_instance(instance)
		
		for reward in rewards:
			if reward is Item:
				reward.get_parent().remove_child(reward)
				quest.get_inventory().item_gain(reward)
		
		instance.queue_free()
