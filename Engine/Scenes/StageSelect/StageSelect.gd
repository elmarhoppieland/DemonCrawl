@tool
extends Control
class_name StageSelect

# ==============================================================================
@onready var _stage_details: StageDetails = %StageDetails
@onready var _quest_name_label: Label = %QuestNameLabel
# ==============================================================================

func _on_quest_changed() -> void:
	if not is_node_ready():
		await ready
	
	if not get_quest():
		_quest_name_label.text = ""
		return
	_quest_name_label.text = get_quest().name


func _on_stage_details_interacted() -> void:
	const FADE_DURATION := 1.0
	var tween := create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Camera2D, "zoom", 4 * Vector2.ONE, FADE_DURATION)
	#Foreground.fade_out(FADE_DURATION)
	await tween.finished
	
	var stage := get_quest().get_selected_stage()
	var instance := stage.create_instance()
	instance.notify_loaded()
	instance.set_as_current()
	
	if stage is SpecialStage:
		get_tree().change_scene_to_packed(stage.get_dest_scene())
	else:
		get_tree().change_scene_to_file("res://Engine/Scenes/StageScene/StageScene.tscn")


func _on_stages_overview_icon_selected(icon: StageIcon) -> void:
	if not is_node_ready():
		await ready
	_stage_details.stage = icon.stage


func get_quest() -> Quest:
	return Quest.get_current()


func _on_abandon_button_pressed() -> void:
	Quest.get_current().lost.emit()
	Quest.get_current().notify_unloaded()
	Quest.clear_current()
	Eternity.save()
	
	get_tree().change_scene_to_file("res://Engine/Scenes/MainMenu/MainMenu.tscn")


func _on_back_to_menu_button_pressed() -> void:
	Quest.get_current().notify_unloaded()
	get_tree().change_scene_to_file("res://Engine/Scenes/MainMenu/MainMenu.tscn")
