@tool
extends TextureRect
class_name ProfileSpecialChest

# ==============================================================================
# SavesManager.get_value("chest_name", ProfileSpecialChest, "default")
static var chest_name: String = Eternal.create("default")
# ==============================================================================

func _enter_tree() -> void:
	if not texture:
		texture = load("res://Assets/Sprites/chests/".path_join(chest_name + ".png"))
