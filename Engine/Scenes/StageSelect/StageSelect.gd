@tool
extends Control
class_name StageSelect

# ==============================================================================
#@export var _quest: Quest : set = _set_quest, get = get_quest
# ==============================================================================
#@onready var _stages_overview: StagesOverview = %StagesOverview
@onready var _stage_details: StageDetails = %StageDetails
@onready var _quest_name_label: Label = %QuestNameLabel
# ==============================================================================

func _on_quest_changed() -> void:
	if not is_node_ready():
		await ready
	
	#_stages_overview.set_quest(get_quest())
	
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
	
	get_quest().get_selected_stage().set_as_current()
	
	if get_quest().get_selected_stage() is SpecialStage:
		get_tree().change_scene_to_packed(get_quest().get_selected_stage().dest_scene)
	else:
		get_tree().change_scene_to_file("res://Engine/Scenes/StageScene/StageScene.tscn")


func _on_stages_overview_icon_selected(icon: StageIcon) -> void:
	if not is_node_ready():
		await ready
	_stage_details.stage = icon.stage


#func _set_quest(quest: Quest) -> void:
	#if Engine.is_editor_hint() and _quest and _quest.changed.is_connected(_on_quest_changed):
		#_quest.changed.disconnect(_on_quest_changed)
	#
	#_quest = quest
	#
	#if Engine.is_editor_hint() and quest and not quest.changed.is_connected(_on_quest_changed):
		#quest.changed.connect(_on_quest_changed)
	#
	#_on_quest_changed()


func get_quest() -> Quest:
	return Quest.get_current()
