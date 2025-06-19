@tool
extends Control
class_name StatusEffectList

# ==============================================================================
@export var manager: StatusEffectsManager = null :
	set(value):
		if manager and manager.changed.is_connected(_update):
			manager.changed.disconnect(_update)
		
		manager = value
		
		_update()
		if value:
			value.changed.connect(_update)
# ==============================================================================
@onready var _status_effects_container: VBoxContainer = %StatusEffectsContainer
# ==============================================================================

func _update() -> void:
	if not is_node_ready():
		await ready
	
	var status_effects := manager.get_status_effects() if manager else ([] as Array[StatusEffect])
	for i in status_effects.size():
		var display: StatusEffectDisplay
		if _status_effects_container.get_child_count() <= i:
			display = load("res://Engine/Resources/Scenes/StatusEffectDisplay.tscn").instantiate()
			_status_effects_container.add_child(display)
		else:
			display = _status_effects_container.get_child(i)
		
		display.status_effect = status_effects[i]
	
	while _status_effects_container.get_child_count() > status_effects.size():
		var child := _status_effects_container.get_child(status_effects.size())
		_status_effects_container.remove_child(child)
		child.queue_free()
	
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
