@tool
extends TextureRect
class_name ProfileSpecialChest

# ==============================================================================
static var chest_name: String = SavesManager.get_value("chest_name", ProfileSpecialChest, "default")
# ==============================================================================

func _enter_tree() -> void:
	if not texture:
		texture = ResourceLoader.load("res://Assets/sprites/chests/".path_join(chest_name + ".png"))
