@tool
extends MainMenuButton

# ==============================================================================

func _ready() -> void:
	pressed.connect(func():
		get_tree().change_scene_to_file("res://engine/scenes/token_shop/token_shop.tscn")
	)
