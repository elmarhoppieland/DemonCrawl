@tool
extends Texture2D
class_name Icon

# ==============================================================================
@export var name := "" :
	set(value):
		name = value
		if IconManager.icon_exists(name):
			_texture = IconManager.get_icon_data(name).create_texture()
		else:
			_texture = null
		emit_changed()
# ==============================================================================
var _texture: Texture2D
# ==============================================================================

func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	if _texture:
		_texture.draw(to_canvas_item, pos, modulate, transpose)


func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	if _texture:
		_texture.draw_rect(to_canvas_item, rect, tile, modulate, transpose)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	if _texture:
		_texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)


func _get_height() -> int:
	if _texture:
		return _texture.get_height()
	return 0


func _get_width() -> int:
	if _texture:
		return _texture.get_width()
	return 0


func _has_alpha() -> bool:
	if _texture:
		return _texture.has_alpha()
	return false


func _is_pixel_opaque(x: int, y: int) -> bool:
	if x < 0:
		return true
	if y < 0:
		return true
	if x >= get_width():
		return true
	if y >= get_height():
		return true
	
	if _texture:
		return _texture.get_image().get_pixel(x, y).a8 == 0
	return true
