@abstract
extends Node
class_name TextureNode

# ==============================================================================
var _texture: Texture2D = null : get = get_texture
# ==============================================================================
signal changed()
# ==============================================================================

func emit_changed() -> void:
	changed.emit()


func get_texture() -> Texture2D:
	if not _texture:
		_texture = _get_texture()
		if _texture and not _texture.changed.is_connected(emit_changed):
			_texture.changed.connect(emit_changed)
	return _texture


## Called when this node's [Texture2D] is queried.
## [br][br]After this is called, the texture is cached and this method is not called
## anymore on this node.
@abstract func _get_texture() -> Texture2D


func clear_texture_cache() -> void:
	_texture = null


func get_width() -> int:
	return get_texture().get_width()


func get_height() -> int:
	return get_texture().get_height()


func get_size() -> Vector2:
	return get_texture().get_size()
