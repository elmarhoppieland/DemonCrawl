@tool
extends TextureRect
class_name ProfileMastery

# ==============================================================================
static var atlas := preload("res://Resources/ProfileMastery_atlas.tres")
static var atlas_position: Vector2i = SavesManager.get_value("atlas_position", ProfileMastery, Vector2i.ZERO) :
	set(value):
		atlas.region.position = Vector2(value) * atlas.region.size
	get:
		return atlas.region.position
# ==============================================================================

func _enter_tree() -> void:
	if not texture:
		texture = atlas
