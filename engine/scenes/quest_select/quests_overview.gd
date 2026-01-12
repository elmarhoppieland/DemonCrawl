extends VBoxContainer
class_name QuestsOverview

# ==============================================================================
var _quest_selection_node: Node
var _quest_details_node: Node
# ==============================================================================
@onready var _quest_selection_container: HBoxContainer = %QuestSelectionContainer
@onready var difficulty_select: TextureRect = %DifficultySelect
@onready var difficulty_select_tooltip_grabber: TooltipGrabber = %TooltipGrabber
# ==============================================================================
signal begin_button_visibility_requested(button_visible: bool)
# ==============================================================================

func _ready() -> void:
	QuestsManager.selected_difficulty.begin_button_visibility_requested.connect(begin_button_visibility_requested.emit)
	
	redraw_quests()


func redraw_quests() -> void:
	if _quest_selection_node:
		_quest_selection_node.queue_free()
	
	_quest_selection_node = QuestsManager.selected_difficulty.get_quest_selection_node()
	
	_quest_selection_container.add_child(_quest_selection_node)
	
	QuestsManager.selected_difficulty.select_quest_index(QuestsManager.selected_quest_index)
	
	difficulty_select.texture = QuestsManager.selected_difficulty.get_icon()
	difficulty_select_tooltip_grabber.text = tr(QuestsManager.selected_difficulty.get_name_id())
	
	if _quest_details_node:
		_quest_details_node.queue_free()
	
	_quest_details_node = QuestsManager.selected_difficulty.get_quest_details_node()
	add_child(_quest_details_node)


func change_difficulty(direction: int) -> void:
	QuestsManager.selected_difficulty.begin_button_visibility_requested.disconnect(begin_button_visibility_requested.emit)
	
	var selected_idx := QuestsManager.selected_difficulty.get_selected_quest_index()
	QuestsManager.change_difficulty(direction)
	selected_idx = clampi(selected_idx, 0, QuestsManager.selected_difficulty.quests.size() - 1)
	QuestsManager.selected_difficulty.select_quest_index(selected_idx)
	
	redraw_quests()
	
	QuestsManager.selected_difficulty.begin_button_visibility_requested.connect(begin_button_visibility_requested.emit)


func _on_difficulty_select_interacted() -> void:
	change_difficulty(+1)


func _on_difficulty_select_second_interacted() -> void:
	change_difficulty(-1)
