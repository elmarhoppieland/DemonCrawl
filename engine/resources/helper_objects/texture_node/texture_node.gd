@abstract
extends Node
class_name TextureNode

# ==============================================================================
var _texture: Texture2D = null : get = get_texture
var _material: Material = null : get = get_material
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


## Returns this object's [Material], to be applied whenever its texture is used.
func get_material() -> Material:
	if _material:
		return _material
	
	var override := _get_material()
	if override:
		_material = override
		return override
	
	var palette := get_palette()
	if palette:
		var shader := ShaderMaterial.new()
		shader.shader = preload("res://engine/scenes/stage_scene/board/cell_object.gdshader")
		shader.set_shader_parameter("palette", palette)
		shader.set_shader_parameter("palette_enabled", true)
		_material = shader
		return shader
	
	return null


## Virtual method to override this object's material. If a value other than [code]null[/code]
## is returned, any other [Material] will be overridden by the returned one.
## [br][br][b]Note:[/b] If [method _get_palette] does not return [code]null[/code],
## that value will be used by default. However, this method will override that [Material]
## if it does not return [code]null[/code].
func _get_material() -> Material:
	return null


## Returns this object's [Color] modulation.
func get_modulate() -> Color:
	return _get_modulate()


## Virtual method to override the return value of [method get_modulate].
func _get_modulate() -> Color:
	return Color.WHITE


## Returns the object's color palette, to be inserted into the cell's shader.
func get_palette() -> Texture2D:
	return _get_palette()


## Virtual method to override the object's color palette, to be inserted into the cell's shader.
func _get_palette() -> Texture2D:
	return null


func clear_texture_cache() -> void:
	_texture = null


func get_width() -> int:
	return get_texture().get_width()


func get_height() -> int:
	return get_texture().get_height()


func get_size() -> Vector2:
	return get_texture().get_size()
