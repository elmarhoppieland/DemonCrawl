extends MarginContainer

# ==============================================================================
@onready var stage_details: StageDetails = %StageDetails
# ==============================================================================

func _enter_tree() -> void:
	Quest.stages = ["forest", "alcove", "machine"]


func _on_stage_details_interacted() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Camera2D, "zoom", 4 * Vector2.ONE, 1)
	tween.parallel().tween_property($ColorRect, "color:a", 1, 1)
	await tween.finished
	
	Quest.current_stage = StagesOverview.selected_stage
	get_tree().change_scene_to_file("res://Board/Board.tscn")


func _on_stages_overview_icon_selected(icon: StageIcon) -> void:
	stage_details.load_stage(icon.stage)
