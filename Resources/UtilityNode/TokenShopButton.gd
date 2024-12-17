@tool
extends MainMenuButton

# ==============================================================================

func _ready() -> void:
	pressed.connect(func():
		get_tree().change_scene_to_file("res://Scenes/TokenShop/TokenShop.tscn")
	)
