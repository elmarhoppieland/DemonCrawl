@tool
extends MainMenuButton

# ==============================================================================

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	pressed.connect(func():
		if Quest.stages.is_empty():
			get_tree().change_scene_to_file("res://Scenes/QuestSelect/QuestSelect.tscn")
		elif Board.state != Board.State.VOID:
			get_tree().change_scene_to_file("res://Board/Board.tscn")
		else:
			get_tree().change_scene_to_file("res://Scenes/StageSelect/StageSelect.tscn")
	)
