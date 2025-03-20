@tool
extends Texture2D
class_name CustomTextureBase

# ==============================================================================
@export var base_script: GDScript = null:
	set(value):
		if not value:
			base_script = null
			_instance = null
			notify_property_list_changed()
			return
		
		if value.get_instance_base_type() != &"Texture2D":
			return
		
		base_script = value
		_instance = value.new()
		notify_property_list_changed()
# ==============================================================================
var _instance: Texture2D :
	set(value):
		if _instance:
			_instance.property_list_changed.disconnect(notify_property_list_changed)
			if _instance.changed.is_connected(_instance_changed):
				_instance.changed.disconnect(_instance_changed)
		
		_instance = value
		
		if _instance:
			_instance.property_list_changed.connect(notify_property_list_changed)
			_instance.changed.connect(_instance_changed)
		
		_instance_changed()
# ==============================================================================

@warning_ignore("shadowed_variable")
func _init(base_script: GDScript = null) -> void:
	self.base_script = base_script


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


func create() -> Texture2D:
	return _instance
	#var instance := base_script.new() as Texture2D
	#for prop in _instance.get_property_list():
		#if prop.usage & PROPERTY_USAGE_STORAGE:
			#instance.set(prop.name, _instance[prop.name])
	#return instance


func _get_property_list() -> Array[Dictionary]:
	if not _instance:
		return []
	
	return _instance.get_property_list().filter(func(a: Dictionary) -> bool:
		return not _is_basic_property(a.name)
	)


func _get(property: StringName) -> Variant:
	if _is_basic_property(property):
		return null
	if _instance:
		return _instance.get(property)
	return null


func _set(property: StringName, value: Variant) -> bool:
	if _is_basic_property(property):
		return false
	
	if property in _instance:
		_instance.set(property, value)
		return true
	
	return false


func _is_basic_property(property: StringName) -> bool:
	if property == &"script":
		return true
	
	return (get_script().get_script_property_list() + ClassDB.class_get_property_list("Texture2D")).any(func(a: Dictionary) -> bool:
		return a.name == property
	)


func _instance_changed() -> void:
	if Engine.is_editor_hint():
		emit_changed()
