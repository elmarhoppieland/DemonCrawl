@tool
extends Control
class_name StatusEffectList

# ==============================================================================
@export var manager: StatusEffectsManager = null :
	set(value):
		if manager:
			if manager.child_order_changed.is_connected(_update):
				manager.child_order_changed.disconnect(_update)
			if manager.changed.is_connected(update_minimum_size):
				manager.changed.disconnect(update_minimum_size)
		
		manager = value
		
		_update()
		if value:
			value.child_order_changed.connect(_update)
			value.changed.connect(update_minimum_size)
# ==============================================================================
@onready var _status_effects_container: VBoxContainer = %StatusEffectsContainer
# ==============================================================================

func _update() -> void:
	if not is_node_ready():
		await ready
	
	var status_effects := manager.get_status_effects() if manager else ([] as Array[StatusEffect])
	for i in maxi(status_effects.size(), _status_effects_container.get_child_count()):
		var display: StatusEffectDisplay
		if i < _status_effects_container.get_child_count():
			display = _status_effects_container.get_child(i)
		else:
			display = load("res://engine/resources/scenes/status_effect_display.tscn").instantiate()
			_status_effects_container.add_child(display)
		
		if i < status_effects.size():
			display.status_effect = status_effects[i]
		else:
			display.queue_free()
	
	update_minimum_size()


func _get_minimum_size() -> Vector2:
	if not is_node_ready():
		return Vector2.ZERO
	
	var width := 0.0
	for child: Control in _status_effects_container.get_children():
		var child_width := child.get_minimum_size().x
		if child_width > width:
			width = child_width
	
	return Vector2(width, 0)
