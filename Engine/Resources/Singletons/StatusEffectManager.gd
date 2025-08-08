@tool
extends Node
class_name StatusEffectsManager

# ==============================================================================
@export var _status_effects: Array[StatusEffect] = [] :
	set(value):
		for status in _status_effects:
			if status and status.changed.is_connected(emit_changed):
				status.changed.disconnect(emit_changed)
			if status and status.finished.is_connected(_status_finished.bind(status)):
				status.finished.disconnect(_status_finished.bind(status))
		
		_status_effects = value
		
		for status in _status_effects:
			if status:
				status.changed.connect(emit_changed)
				status.finished.connect(_status_finished.bind(status), CONNECT_ONE_SHOT)
				status.notify_loaded.call_deferred()
		
		emit_changed()
# ==============================================================================
signal changed()
# ==============================================================================

func emit_changed() -> void:
	changed.emit()


func _init() -> void:
	name = "StatusManager"


func get_quest() -> Quest:
	var base := get_parent()
	while base != null and base is not Quest:
		base = base.get_parent()
	return base


func get_status_effects() -> Array[StatusEffect]:
	return _status_effects


func add_status_effect(status_effect: StatusEffect) -> void:
	if status_effect not in _status_effects:
		_status_effects.append(status_effect)
		
		status_effect.changed.connect(emit_changed)
		status_effect.finished.connect(_status_finished.bind(status_effect), CONNECT_ONE_SHOT)
		
		status_effect.notify_loaded()
	
	emit_changed()


func _status_finished(status_effect: StatusEffect) -> void:
	_status_effects.erase(status_effect)
	emit_changed()
