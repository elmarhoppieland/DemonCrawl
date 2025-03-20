@tool
extends TextureSequence
class_name AnimatedTextureSequence

# ==============================================================================
@export var duration := 1.0 :
	set(value):
		duration = value
		emit_changed()
		_area_changed.emit(get_tiles_area())
# ==============================================================================
var elapsed := 0.0
var tween: Tween
# ==============================================================================

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if tween:
			tween.kill()


func _validate_property(property: Dictionary) -> void:
	if property.name == &"index":
		property.usage &= ~PROPERTY_USAGE_EDITOR


func _init() -> void:
	_area_changed.connect(func(area: int) -> void:
		if not get_tree():
			await Promise.defer()
		
		if tween:
			tween.kill()
		if get_tiles_area() == 0:
			tween = null
			return
		
		tween = get_tree().root.create_tween().set_loops()
		tween.tween_interval(duration / area)
		tween.tween_callback(next)
	)


func get_tree() -> SceneTree:
	return Engine.get_main_loop()
