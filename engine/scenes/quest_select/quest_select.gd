extends Control
class_name QuestSelect

# ==============================================================================
var _focused_node: CanvasItem
# ==============================================================================
@onready var begin_button_container: MarginContainer = %BeginButtonContainer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================

func _on_begin_button_pressed() -> void:
	var quest := QuestsManager.selected_difficulty.begin_selected_quest()
	quest.source_difficulty = QuestsManager.selected_difficulty
	quest.set_as_current()
	
	QuestsManager.selected_difficulty.apply_starting_values(quest)
	
	GuiLayer.get_statbar().quest = quest
	
	quest.start()
	
	Eternity.save()
	
	get_tree().change_scene_to_file("res://engine/scenes/stage_select/stage_select.tscn")
	
	#Effects.quest_start(quest)
	
	#quest.notify_loaded()


func _on_quest_select_statbar_edit_equipment() -> void:
	Focus.get_instance().hide()
	_focused_node = Focus.get_focused_node()
	animation_player.play("equipment_edit")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://engine/scenes/main_menu/main_menu.tscn")


func _on_edit_equipment_back_button_pressed() -> void:
	Focus.move_to(_focused_node, true)
	animation_player.play("equipment_edit_back")


func _on_quests_overview_begin_button_visibility_requested(button_visible: bool) -> void:
	if not is_node_ready():
		await ready
	begin_button_container.visible = button_visible
