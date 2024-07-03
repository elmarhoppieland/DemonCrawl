extends CanvasLayer
class_name StatusEffectsOverlay

# ==============================================================================
static var _instance: StatusEffectsOverlay

static var _status_effects := {}
# ==============================================================================
@onready var _status_effect_container: VBoxContainer = %StatusEffectContainer
# ==============================================================================

static func add_status_effect(status_effect: StatusEffect, id: String) -> void:
	_instance._status_effect_container.add_child(status_effect)
	_status_effects[id] = status_effect


static func has_status_effect(id: String) -> bool:
	return id in _status_effects


static func get_status_effect(id: String) -> StatusEffect:
	return _status_effects.get(id)


static func remove_status_effect(status_effect: StatusEffect, keep_instance: bool = false) -> void:
	_instance._status_effect_container.remove_child(status_effect)
	
	if not keep_instance:
		status_effect.queue_free()
