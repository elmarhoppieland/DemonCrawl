extends Control
class_name QuestSelect

# ==============================================================================
var _focused_node: CanvasItem
# ==============================================================================
@onready var quest_name_label: Label = %QuestNameLabel
@onready var lore_label: Label = %LoreLabel
@onready var begin_button_container: MarginContainer = %BeginButtonContainer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================

func _on_quests_overview_quest_selected(quest: QuestFile, difficulty: Difficulty) -> void:
	QuestsManager.selected_quest = quest
	QuestsManager.selected_difficulty = difficulty
	
	if not is_node_ready():
		await ready
	
	var state := QuestsManager.get_quest_state(quest, difficulty)
	
	if not QuestsManager.is_quest_unlocked(quest, difficulty):
		quest_name_label.text = tr("LOCKED")
		lore_label.text = tr("LORE_LOCKED") if state == QuestsManager.QuestState.LOCKED_NEEDS_PURCHASE else tr("LORE_LOCKED_CASUAL")
		begin_button_container.hide()
	else:
		quest_name_label.text = tr(quest.name)
		lore_label.text = tr(quest.lore)
		begin_button_container.show()


func _on_begin_button_pressed() -> void:
	var quest := QuestsManager.selected_quest.generate()
	quest.source_difficulty = QuestsManager.selected_difficulty
	quest.set_as_current()
	
	QuestsManager.selected_difficulty.apply_starting_values(quest)
	
	quest.start()
	
	get_tree().change_scene_to_file("res://Engine/Scenes/StageSelect/StageSelect.tscn")
	
	Eternity.save()
	
	Effects.quest_start(quest)
	
	#quest.notify_loaded()


func _on_quest_select_statbar_edit_equipment() -> void:
	Focus.get_instance().hide()
	_focused_node = Focus.get_focused_node()
	animation_player.play("equipment_edit")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Engine/Scenes/MainMenu/MainMenu.tscn")


func _on_edit_equipment_back_button_pressed() -> void:
	Focus.move_to(_focused_node, true)
	animation_player.play("equipment_edit_back")
