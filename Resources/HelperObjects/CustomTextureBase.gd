@tool
extends Texture2D
class_name CustomTextureBase

# ==============================================================================
@export var _instance: Texture2D :
	set(value):
		if _instance and _instance.changed.is_connected(_instance_changed):
			_instance.changed.disconnect(_instance_changed)
		
		_instance = value
		
		if _instance:
			_instance.changed.connect(_instance_changed)
		
		_instance_changed()
# ==============================================================================

func create() -> Texture2D:
	return _instance


func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	if _instance and Engine.is_editor_hint():
		_instance.draw(to_canvas_item, pos, modulate, transpose)


func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	if _instance and Engine.is_editor_hint():
		_instance.draw_rect(to_canvas_item, rect, tile, modulate, transpose)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	if _instance and Engine.is_editor_hint():
		_instance.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)


func _get_width() -> int:
	if _instance and Engine.is_editor_hint():
		return _instance.get_width()
	return 0


func _get_height() -> int:
	if _instance and Engine.is_editor_hint():
		return _instance.get_height()
	return 0


func _has_alpha() -> bool:
	if _instance and Engine.is_editor_hint():
		return _instance.has_alpha()
	return false


func _instance_changed() -> void:
	if Engine.is_editor_hint():
		emit_changed()
