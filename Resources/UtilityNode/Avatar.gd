@tool
extends TextureRect
class_name Avatar

# ==============================================================================
const SIZE := Vector2i(16, 16)
# ==============================================================================
static var atlas := preload("res://Resources/UtilityNode/Avatar_atlas.tres")
# SavesManager.get_value("atlas_position", Avatar, Vector2i(1, 0))
static var atlas_position: Vector2i = Eternal.create(Vector2i(1, 0)) :
	set(value):
		atlas_position = value
		atlas.region.position = Vector2(atlas_position * Avatar.SIZE)
# ==============================================================================

func _enter_tree() -> void:
	if not texture:
		texture = atlas
