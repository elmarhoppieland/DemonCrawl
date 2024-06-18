extends Control
class_name QuestSelect

# ==============================================================================
static var selected_quest: QuestFile
static var selected_quest_index := -1 :
	get:
		if selected_quest:
			return selected_quest_index
		return -1
# ==============================================================================
@onready var quest_name_label: Label = %QuestNameLabel
@onready var lore_label: Label = %LoreLabel
@onready var begin_button_container: MarginContainer = %BeginButtonContainer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================

func _on_quests_overview_quest_selected(quest: QuestFile, _difficulty: DifficultyFile) -> void:
	selected_quest = quest
	selected_quest_index = quest.get_meta("index")
	
	if not quest_name_label:
		await ready
	
	if quest.get_meta("locked"):
		quest_name_label.text = tr("LOCKED")
		lore_label.text = tr("LORE_LOCKED") if QuestsOverview.selected_difficulty.requires_token_shop_purchase() else tr("LORE_LOCKED_CASUAL")
		begin_button_container.hide()
	else:
		quest_name_label.text = tr(quest.get_name())
		lore_label.text = tr(quest.get_lore())
		begin_button_container.show()


func _on_begin_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/StageSelect/StageSelect.tscn")


func _on_quest_select_statbar_edit_equipment() -> void:
	Focus.hide()
	Focus.save_current()
	animation_player.play("equipment_edit")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")


func _on_edit_equipment_back_button_pressed() -> void:
	Focus.load_saved()
	animation_player.play("equipment_edit_back")
