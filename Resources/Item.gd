extends RefCounted
class_name Item

# ==============================================================================
var _texture_cache: Texture2D
# ==============================================================================
signal inventory_added()
signal gained()
# ==============================================================================

func _init() -> void:
	inventory_added.connect(_inventory_added)
	gained.connect(_gained)


func create_node() -> Node:
	var texture_rect := TextureRect.new()
	texture_rect.texture = create_texture()
	return texture_rect


func create_texture() -> Texture2D:
	if _texture_cache:
		return _texture_cache
	
	_texture_cache = Item.get_base_atlas().duplicate()
	_texture_cache.region.position = get_script().get_atlas_position() * Vector2i(16, 16) as Vector2
	return _texture_cache


func get_name() -> String:
	return (get_script() as Script).resource_path.get_file().get_basename()


static func get_atlas_position() -> Vector2i:
	return Vector2i.ZERO


static func get_base_atlas() -> AtlasTexture:
	return preload("res://Resources/ItemAtlas.tres")


func _inventory_added() -> void:
	pass


func _gained() -> void:
	pass
