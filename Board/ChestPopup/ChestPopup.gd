extends CanvasLayer
class_name ChestPopup

# ==============================================================================
static var _instance: ChestPopup
# ==============================================================================
@onready var rewards_container: HBoxContainer = %RewardsContainer
@onready var coin_value: CoinValue = %CoinValue
@onready var string_table_label: StringTableLabel = %StringTableLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================

func _init() -> void:
	_instance = self


func _exit_tree() -> void:
	if _instance == self:
		_instance = null


func _process(_delta: float) -> void:
	if visible and Input.is_action_just_pressed("interact"):
		animation_player.play("popup_hide")


func _show_items() -> void:
	while rewards_container.get_child_count() > 0:
		var child := rewards_container.get_child(0)
		rewards_container.remove_child(child)
		child.queue_free()
	
	rewards_container.show()
	coin_value.hide()
	
	animation_player.play("popup_show")
	
	var count: int = EffectManager.propagate_posnum("get_chest_reward_count", [], 1)
	var max_cost: int = EffectManager.propagate_posnum("get_chest_item_max_cost", [], 4 * StagesOverview.selected_stage.max_power + 3)
	
	var has_omen := false
	var rewards: Array[Collectible] = []
	for i in count:
		if RNG.randi() % 9 == 0:
			rewards.append(ItemDB.create_filter().disallow_all_types().allow_type(Item.Type.OMEN).get_random_item())
			has_omen = true
		else:
			rewards.append(ItemDB.create_filter().disallow_type(Item.Type.OMEN).set_max_cost(max_cost).get_random_item())
	
	if has_omen:
		string_table_label.table_name = "Chest-Omen"
	else:
		string_table_label.table_name = "Chest-Item"
	
	string_table_label.generate()
	
	rewards = EffectManager.propagate_value("get_chest_rewards", [], rewards)
	
	for reward in rewards:
		var display := CollectibleDisplay.create(reward)
		display.show_focus = false
		rewards_container.add_child(display)
		
		if reward is Item:
			Inventory.gain_item(reward.duplicate())


func _show_coins() -> void:
	rewards_container.hide()
	coin_value.show()
	
	animation_player.play("popup_show")
	
	string_table_label.table_name = "Chest-Coins"
	
	string_table_label.generate()
	
	coin_value.coin_value = RNG.randi_range(0, 2 * StagesOverview.selected_stage.max_power + 6)


static func show_rewards() -> void:
	if RNG.randi() % 2 == 0:
		_instance._show_items()
	else:
		_instance._show_coins()
