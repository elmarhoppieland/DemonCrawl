@tool
extends Texture2D
class_name CustomTextureBase

# ==============================================================================
static var _initalized := false
# ==============================================================================
@export var _instance: Texture2D
# ==============================================================================

static func _static_init() -> void:
	if _initalized:
		return
	_initalized = true
	
	CustomTexturePreview.add_remap(CustomTextureBase, "_instance")


func _init(texture: Texture2D = null) -> void:
	_instance = texture


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
