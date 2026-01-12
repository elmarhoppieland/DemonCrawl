@tool
extends HBoxContainer
class_name DefaultQuestSelection

# ==============================================================================
@export var difficulty: Difficulty
# ==============================================================================
var selected_quest: QuestFile
# ==============================================================================
@onready var _quest_icons_container: HBoxContainer = %QuestIconsContainer
@onready var _player_data_label: Label = %PlayerDataLabel
# ==============================================================================
signal quest_selected(quest: QuestFile)
# ==============================================================================

func clear() -> void:
	for child in _quest_icons_container.get_children():
		child.queue_free()


func add_quest(quest: QuestFile) -> void:
	var icon := TextureRect.new()
	icon.name = quest.name
	
	var locked := not difficulty.is_quest_unlocked(quest)
	
	if locked:
		icon.texture = IconManager.get_icon_data("quest/locked").create_texture()
	else:
		icon.texture = quest.icon
	
	var focus_grabber := FocusGrabber.new()
	focus_grabber.main = quest == selected_quest
	icon.add_child(focus_grabber)
	
	focus_grabber.interacted.connect(select_quest.bind(quest))
	
	if not is_node_ready():
		await ready
	
	_quest_icons_container.add_child(icon)


func select_quest(quest: QuestFile) -> void:
	selected_quest = quest
	
	var data := QuestsManager.get_completion_data(quest)
	var completions := data.completion_count
	var best := data.best_score
	_player_data_label.text = ("%s: x%d\n%s: %s" % [
		tr("quest-select.overview.quest-completions"),
		completions,
		tr("quest-select.overview.best"),
		str(best) if completions > 0 else "-"
	])
	
	var index := difficulty.quests.find(quest)
	assert(index >= 0, "Given quest is not a part of the selected difficulty.")
	
	QuestsManager.selected_quest_index = index
	
	quest_selected.emit(quest)
	
	get_tree().process_frame.connect((_quest_icons_container.get_child(index).get_child(0) as FocusGrabber).interact, CONNECT_ONE_SHOT)
