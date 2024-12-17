extends TextureRect
class_name ChangePageButton

# ==============================================================================
enum Direction {
	LEFT = -1,
	RIGHT = 1
}
# ==============================================================================
@export var direction := Direction.LEFT
@export var target: Node
# ==============================================================================
var mouse_is_inside := false
# ==============================================================================

func _ready() -> void:
	var tween: Array[Tween] = [null]
	mouse_entered.connect(func():
		if tween[0]:
			tween[0].kill()
		tween[0] = create_tween()
		tween[0].tween_method(set_inversion, 0.0, 1.0, 0.2)
		mouse_is_inside = true
	)
	mouse_exited.connect(func():
		if tween[0]:
			tween[0].kill()
		tween[0] = create_tween()
		tween[0].tween_method(set_inversion, 1.0, 0.0, 0.2)
		mouse_is_inside = false
	)


func _process(_delta: float) -> void:
	if mouse_is_inside and Input.is_action_just_pressed("interact"):
		if target and target.has_method("change_page"):
			target.change_page(direction)
		else:
			Debug.log_error("Could not change page since the target (%s) does not have a change_page() method." % (target.name if target else &"<null>"))


func set_inversion(inversion: float) -> void:
	(material as ShaderMaterial).set_shader_parameter("inversion", inversion)
