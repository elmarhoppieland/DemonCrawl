@tool
extends TextureRect
class_name Avatar

# ==============================================================================
const SIZE := Vector2i(16, 16)
# ==============================================================================
static var atlas := preload("res://Resources/Avatar_atlas.tres")
static var atlas_position: Vector2i = SavesManager.get_value("atlas_position", Avatar, Vector2i(1, 0)) :
	set(value):
		atlas_position = value
		atlas.region.position = Vector2(atlas_position * Avatar.SIZE)
# ==============================================================================

func _enter_tree() -> void:
	if not texture:
		texture = atlas
