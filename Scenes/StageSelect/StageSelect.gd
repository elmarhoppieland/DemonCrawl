extends MarginContainer
class_name StageSelect

# ==============================================================================
@onready var stage_details: StageDetails = %StageDetails
@onready var quest_name_label: Label = %QuestNameLabel
# ==============================================================================

func _ready() -> void:
	Eternity.save()
	
	quest_name_label.text = Quest.quest_name


func _on_stage_details_interacted() -> void:
	const FADE_DURATION := 1.0
	var tween := create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Camera2D, "zoom", 4 * Vector2.ONE, FADE_DURATION)
	Foreground.fade_out(FADE_DURATION)
	await tween.finished
	
	if StagesOverview.selected_stage is SpecialStage:
		get_tree().change_scene_to_packed(StagesOverview.selected_stage.dest_scene)
	else:
		get_tree().change_scene_to_file("res://Board/Board.tscn")


func _on_stages_overview_icon_selected(icon: StageIcon) -> void:
	stage_details.stage = icon.stage
