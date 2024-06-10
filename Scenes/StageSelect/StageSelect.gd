extends MarginContainer

# ==============================================================================
@onready var stage_details: StageDetails = %StageDetails
@onready var quest_name_label: Label = %QuestNameLabel
# ==============================================================================

func _ready() -> void:
	SavesManager.save()
	
	quest_name_label.text = Quest.quest_name


func _on_stage_details_interacted() -> void:
	const FADE_DURATION := 1.0
	var tween := create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Camera2D, "zoom", 4 * Vector2.ONE, FADE_DURATION)
	Foreground.fade_out(FADE_DURATION)
	await tween.finished
	
	get_tree().change_scene_to_packed(preload("res://Board/Board.tscn"))


func _on_stages_overview_icon_selected(icon: StageIcon) -> void:
	stage_details.stage = icon.stage
