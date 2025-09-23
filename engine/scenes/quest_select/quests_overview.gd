extends VBoxContainer
class_name QuestsOverview

# ==============================================================================
var quest_icons: Array[TextureRect] = []
# ==============================================================================
@onready var quest_icons_container: HBoxContainer = %QuestIconsContainer
@onready var difficulty_select: TextureRect = %DifficultySelect
@onready var difficulty_select_tooltip_grabber: TooltipGrabber = %TooltipGrabber
@onready var player_data_label: Label = %PlayerDataLabel
# ==============================================================================
signal quest_selected(quest: QuestFile, difficulty: Difficulty)
# ==============================================================================

func _ready() -> void:
	redraw_quests()


func redraw_quests() -> void:
	for icon in quest_icons:
		icon.queue_free()
	
	quest_icons.clear()
	
	difficulty_select.texture = QuestsManager.selected_difficulty.icon
	difficulty_select_tooltip_grabber.text = tr(QuestsManager.selected_difficulty.name)
	
	for quest in QuestsManager.selected_difficulty.quests:
		add_quest(quest)


func add_quest(quest: QuestFile) -> void:
	var icon := TextureRect.new()
	icon.name = quest.name
	
	var locked := not QuestsManager.is_quest_unlocked(quest)
	
	if locked:
		icon.texture = IconManager.get_icon_data("quest/locked").create_texture()
	else:
		icon.texture = quest.icon
	
	var focus_grabber := FocusGrabber.new()
	focus_grabber.main = quest == QuestsManager.selected_quest
	icon.add_child(focus_grabber)
	
	focus_grabber.interacted.connect(func() -> void:
		QuestsManager.selected_quest = quest
		
		var data := QuestsManager.get_completion_data(quest)
		var completions := data.completion_count
		var best := data.best_score
		player_data_label.text = ("%s: x%d\n%s: %s" % [
			tr("quest-select.overview.quest-completions"),
			completions,
			tr("quest-select.overview.best"),
			str(best) if completions > 0 else "-"
		])
		
		quest_selected.emit(quest, QuestsManager.selected_difficulty)
	)
	
	quest_icons_container.add_child(icon)
	
	quest_icons.append(icon)


func change_difficulty(direction: int) -> void:
	var selected_idx := QuestsManager.selected_difficulty.quests.find(QuestsManager.selected_quest)
	QuestsManager.change_difficulty(direction)
	selected_idx = clampi(selected_idx, 0, QuestsManager.selected_difficulty.quests.size() - 1)
	QuestsManager.selected_quest = QuestsManager.selected_difficulty.quests[selected_idx]
	redraw_quests()


func _on_difficulty_select_interacted() -> void:
	change_difficulty(+1)


func _on_difficulty_select_second_interacted() -> void:
	change_difficulty(-1)
