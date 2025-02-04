extends CanvasLayer
class_name ChestPopup

# ==============================================================================
static var _instance: ChestPopup
# ==============================================================================
var cell: Cell
# ==============================================================================
@onready var rewards_container: HBoxContainer = %RewardsContainer
@onready var coin_value: CoinValue = %CoinValue
@onready var string_table_label: StringTableLabel = %StringTableLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================

func _enter_tree() -> void:
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
	
	var count := Effects.get_chest_reward_count(1, cell)
	var max_cost := Effects.get_chest_item_max_cost(4 * Quest.get_current().get_selected_stage().max_power + 3, cell)
	
	var has_omen := false
	var rewards: Array[Collectible] = []
	for i in count:
		if randi() % 9 == 0:
			rewards.append(ItemDB.create_filter().disallow_all_types().allow_type(Item.Type.OMEN).get_random_item())
			has_omen = true
		else:
			rewards.append(ItemDB.create_filter().disallow_type(Item.Type.OMEN).set_min_cost(1).set_max_cost(max_cost).get_random_item())
	
	if has_omen:
		string_table_label.table_name = "Chest-Omen"
	else:
		string_table_label.table_name = "Chest-Item"
	
	string_table_label.generate()
	
	rewards = Effects.get_chest_rewards(rewards, cell)
	
	for reward in rewards:
		var display := LargeCollectibleDisplay.create(reward)
		display.show_focus = false
		rewards_container.add_child(display)
		
		if reward is Item:
			Quest.get_current().get_inventory().item_gain(reward.duplicate())


func _show_coins() -> void:
	rewards_container.hide()
	coin_value.show()
	
	animation_player.play("popup_show")
	
	string_table_label.table_name = "Chest-Coins"
	
	string_table_label.generate()
	
	coin_value.coin_value = randi_range(0, 2 * Quest.get_current().get_selected_stage().max_power + 6)


static func show_rewards() -> void:
	if randi() % 2 == 0:
		_instance._show_items()
	else:
		_instance._show_coins()
