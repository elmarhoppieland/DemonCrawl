@tool
extends MainMenuButton

# ==============================================================================

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	pressed.connect(func() -> void:
		if not Quest.has_current():
			get_tree().change_scene_to_file("res://engine/scenes/quest_select/quest_select.tscn")
		elif Quest.get_current().has_current_stage():
			GuiLayer.get_statbar().quest = Quest.get_current()
			var stage := Quest.get_current().get_current_stage_base()
			SceneManager.change_scene_to_custom(stage.create_scene)
			stage.play()
		else:
			GuiLayer.get_statbar().quest = Quest.get_current()
			get_tree().change_scene_to_file("res://engine/scenes/stage_select/stage_select.tscn")
	)
