extends MarginContainer

# ==============================================================================
var mouse_is_inside := false
# ==============================================================================

func _ready() -> void:
	const ANIM_DURATION := 0.1
	mouse_entered.connect(func():
		create_tween().tween_property($Hovered, "modulate:a", 1.0, ANIM_DURATION)
		Tooltip.show_text(tr("RETURN_TO_MAIN_MENU"))
		mouse_is_inside = true
	)
	mouse_exited.connect(func():
		create_tween().tween_property($Hovered, "modulate:a", 0.0, ANIM_DURATION)
		Tooltip.hide_text()
		mouse_is_inside = false
	)


func _process(_delta: float) -> void:
	if (mouse_is_inside and Input.is_action_just_pressed("interact")) or Input.is_action_just_pressed("back"):
		get_tree().change_scene_to_file("res://Engine/Scenes/MainMenu/MainMenu.tscn")
