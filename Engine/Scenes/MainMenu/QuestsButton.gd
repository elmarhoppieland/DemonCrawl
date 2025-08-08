@tool
extends MainMenuButton

# ==============================================================================

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	pressed.connect(func() -> void:
		if not Quest.has_current():
			get_tree().change_scene_to_file("res://Engine/Scenes/QuestSelect/QuestSelect.tscn")
		elif Quest.get_current().has_current_stage():
			#Quest.get_current().notify_loaded()
			#Quest.get_current().get_current_stage().notify_loaded()
			Quest.get_current().get_current_stage().change_to_scene()
		else:
			#Quest.get_current().notify_loaded()
			get_tree().change_scene_to_file("res://Engine/Scenes/StageSelect/StageSelect.tscn")
	)
