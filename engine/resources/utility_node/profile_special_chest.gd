@tool
extends TextureRect
class_name ProfileSpecialChest

# ==============================================================================
static var chest_name: String = Eternal.create("default")
# ==============================================================================

func _enter_tree() -> void:
	if not texture:
		texture = load("res://assets/sprites/chests/".path_join(chest_name + ".png"))
