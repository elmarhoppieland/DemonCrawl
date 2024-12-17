@tool
extends MainMenuButton

# ==============================================================================

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	pressed.connect(func():
		if not Quest.has_current():
			get_tree().change_scene_to_file("res://Scenes/QuestSelect/QuestSelect.tscn")
		elif Stage.has_current():
			get_tree().change_scene_to_file("res://Scenes/StageScene/StageScene.tscn")
		else:
			get_tree().change_scene_to_file("res://Scenes/StageSelect/StageSelect.tscn")
	)
