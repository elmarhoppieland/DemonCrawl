@tool
extends MainMenuButton

# ==============================================================================

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	pressed.connect(func() -> void:
		if not Quest.has_current():
			get_tree().change_scene_to_file("res://Engine/Scenes/QuestSelect/QuestSelect.tscn")
		elif StageInstance.has_current():
			Quest.get_current().notify_loaded()
			StageInstance.get_current().notify_loaded()
			get_tree().change_scene_to_file("res://Engine/Scenes/StageScene/StageScene.tscn")
		else:
			Quest.get_current().notify_loaded()
			get_tree().change_scene_to_file("res://Engine/Scenes/StageSelect/StageSelect.tscn")
	)
