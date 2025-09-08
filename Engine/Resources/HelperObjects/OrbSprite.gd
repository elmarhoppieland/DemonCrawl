extends Node2D
class_name OrbSprite

# ==============================================================================
@export var orb: Orb = null
# ==============================================================================
var direction := 0.0

var half_bounds := Rect2()
# ==============================================================================

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	
	position += delta * Vector2.RIGHT.rotated(direction) * orb.get_speed()
	
	for axis in [Vector2.AXIS_X, Vector2.AXIS_Y]:
		if position[axis] > half_bounds.position[axis] + half_bounds.size[axis] - get_size()[axis] / 2:
			position[axis] = half_bounds.position[axis] + half_bounds.size[axis] - get_size()[axis] / 2
		elif position[axis] < half_bounds.position[axis] - half_bounds.size[axis] + get_size()[axis] / 2:
			position[axis] = half_bounds.position[axis] - half_bounds.size[axis] + get_size()[axis] / 2
		else:
			continue
		
		if axis == Vector2.AXIS_X:
			direction = PI - direction
		else:
			direction = -direction


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and is_hovered():
		notify_clicked()
		get_viewport().set_input_as_handled()


func notify_clicked() -> void:
	_clicked()
	orb.notify_clicked()


func _clicked() -> void:
	pass


func get_size() -> Vector2:
	return _get_size()


func _get_size() -> Vector2:
	return Vector2.ZERO


func is_hovered() -> bool:
	return not DCPopup.is_popup_visible() and _is_hovered()


func _is_hovered() -> bool:
	return false
