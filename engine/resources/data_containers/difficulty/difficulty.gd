extends DifficultyBase
class_name Difficulty

# ==============================================================================
@export var name := ""  ## The name of the difficulty.
@export var icon: Texture2D = null  ## The icon of the difficulty.

@export var conditions: Array[Condition] = []

@export var quests: Array[QuestFile] = []  ## This difficulty's quests.

@export var guaranteed_chests := 1 ## The number of guaranteed chests per stage.

@export_group("Starting Stats")
@export var max_life := 5  ## The amount of max lives the player should start each quest with.
@export var life := 5  ## The amount of lives the player should start each quest with. Should never be higher than [property max_life].
@export var revives := 0  ## The number of revives the player should start each quest with.
@export var defense := 0  ## The amount of defense the player should start each quest with.
@export var coins := 0  ## The amount of coins the player should start each quest with.
# ==============================================================================
var quest_selection: DefaultQuestSelection
var quest_details: DefaultQuestDetails
# ==============================================================================

func _get_name_id() -> String:
	return name


func _get_icon() -> Texture2D:
	return icon


func _begin_selected_quest() -> Quest:
	return quest_selection.selected_quest.generate()


func _apply_starting_values(quest: Quest) -> void:
	quest.get_stats().max_life = max_life
	quest.get_stats().life = life
	quest.get_stats().revives = revives
	quest.get_stats().defense = defense
	quest.get_stats().coins = coins


func _get_quest_selection_node() -> Node:
	quest_selection = load("res://assets/quests/default_quest_selection.tscn").instantiate()
	quest_selection.difficulty = self
	for quest in quests:
		quest_selection.add_quest(quest)
	return quest_selection


func _get_quest_details_node() -> Node:
	quest_details = load("res://assets/quests/default_quest_details.tscn").instantiate()
	
	_update_quest_details(quest_selection.selected_quest)
	quest_selection.quest_selected.connect(_update_quest_details)
	
	return quest_details


func _update_quest_details(quest: QuestFile) -> void:
	var state := QuestsManager.get_quest_state(quest, self)
	
	if not is_quest_unlocked(quest):
		quest_details.quest_name = tr("quest-select.quest.locked")
		quest_details.quest_lore = tr("quest-select.quest.locked.lore") if state == QuestsManager.QuestState.LOCKED_NEEDS_PURCHASE else tr("quest-select.quest.locked.lore-casual")
		hide_begin_button()
	else:
		quest_details.quest_name = tr(quest.name)
		quest_details.quest_lore = tr(quest.lore)
		show_begin_button()


func _get_selected_quest_index() -> int:
	if not quest_selection:
		return 0
	return quests.find(quest_selection.selected_quest)


func _select_quest_index(quest_index: int) -> void:
	if not quest_selection:
		return
	
	quest_index = clampi(quest_index, 0, quests.size() - 1)
	
	quest_selection.select_quest(quests[quest_index])


func is_quest_unlocked(quest: QuestFile) -> bool:
	var quest_index := quests.find(quest)
	if quest_index < 0:
		Debug.log_error("The provided quest (%s) is not a part of the provided difficulty (%s)." % [quest.name, name])
		return false
	
	for i in quest_index:
		var previous_quest := quests[i]
		if previous_quest.skip_unlock:
			continue
		if QuestsManager.get_completion_data(previous_quest).completion_count > 0:
			continue
		return false
	
	if quest.token_shop_purchase != null:
		return TokenShop.is_item_purchased(quest.token_shop_purchase)
	return true


func _parse_guaranteed_objects(guaranteed_objects: Array[CellObject]) -> Array[CellObject]:
	for i in guaranteed_chests:
		var chest := TreasureChest.new()
		guaranteed_objects.append(chest)
	return guaranteed_objects


func _is_unlocked() -> bool:
	for condition in conditions:
		if not condition.is_met():
			return false
	
	return true
