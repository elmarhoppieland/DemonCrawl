extends DCPopup
class_name ChestPopup

# ==============================================================================
static var _instance: ChestPopup
# ==============================================================================
var cell: CellData
# ==============================================================================
@onready var _rewards_container: HBoxContainer = %RewardsContainer
@onready var _coin_value: CoinValue = %CoinValue
@onready var _string_table_label: StringTableLabel = %StringTableLabel
# ==============================================================================

func _enter_tree() -> void:
	super()
	
	_instance = self


func _exit_tree() -> void:
	if _instance == self:
		_instance = null


func _show_items(chest: TreasureChest) -> void:
	show()
	
	var quest := chest.get_quest()
	
	#while _rewards_container.get_child_count() > 0:
		#var child := _rewards_container.get_child(0)
		#child.queue_free()
		#_rewards_container.remove_child(child)
	
	_rewards_container.show()
	_coin_value.hide()
	
	var count: int = EffectManager.propagate(chest.get_stage_instance().get_effects().get_object_value, [chest, 1, &"reward_count"], 1)
	var max_cost: int = EffectManager.propagate(chest.get_stage_instance().get_effects().get_object_value, [chest, 4 * Quest.get_current().get_selected_stage().max_power + 3, &"reward_max_cost"], 1)
	
	var has_omen := false
	var rewards: Array[Collectible] = []
	for i in count:
		if randi() % 9 == 0:
			rewards.append(quest.get_item_pool().create_filter().disallow_all_types().allow_type(OmenItem).get_random_item().create())
			has_omen = true
		else:
			rewards.append(quest.get_item_pool().create_filter().disallow_type(OmenItem).set_min_cost(1).set_max_cost(max_cost).get_random_item().create())
	
	if has_omen:
		_string_table_label.table = load("res://Assets/StringTables/Chest/Omen.tres")
	else:
		_string_table_label.table = load("res://Assets/StringTables/Chest/Item.tres")
	
	_string_table_label.generate()
	
	rewards = EffectManager.propagate(chest.get_stage_instance().get_effects().get_object_value, [chest, rewards, &"rewards"], 1)
	
	for i in maxi(rewards.size(), _rewards_container.get_child_count()):
		var frame: Frame
		if i < _rewards_container.get_child_count():
			frame = _rewards_container.get_child(i)
		else:
			frame = Frame.create(CollectibleDisplay.create())
			frame.show_focus = false
			_rewards_container.add_child(frame)
		
		if i < rewards.size():
			var reward := rewards[i]
			var display: CollectibleDisplay = frame.get_content()
			if display.collectible != reward:
				if display.collectible and display.is_ancestor_of(display.collectible):
					display.collectible.queue_free()
				
				display.collectible = reward
				display.add_child(reward)
		else:
			frame.queue_free()
	
	#for reward in rewards:
		#var frame := Frame.create(CollectibleDisplay.create(reward, true))
		#frame.show_focus = false
		#_rewards_container.add_child(frame)
	
	popup_show()
	await popup_hidden
	
	for reward in rewards:
		if reward is Item:
			reward.get_parent().remove_child(reward)
			quest.get_inventory().item_gain(reward)


func _show_coins(chest: TreasureChest) -> void:
	_rewards_container.hide()
	_coin_value.show()
	
	_string_table_label.table = load("res://Assets/StringTables/Chest/Coins.tres")
	
	var coins: int = EffectManager.propagate(chest.get_stage_instance().get_effects().get_object_value, [chest, randi_range(6, 2 * Quest.get_current().get_selected_stage().max_power + 6), &"coins"], 1)
	
	_string_table_label.generate({"coins": coins})
	
	_coin_value.coin_value = coins
	
	popup_show()
	await popup_hidden
	
	Quest.get_current().get_stats().coins += coins


static func show_rewards(chest: TreasureChest) -> void:
	while _instance._popup_visible:
		await _instance.popup_hidden
	
	if randi() % 2 == 0:
		_instance._show_items(chest)
	else:
		_instance._show_coins(chest)
