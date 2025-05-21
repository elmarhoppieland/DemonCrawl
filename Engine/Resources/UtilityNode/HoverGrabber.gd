extends Grabber
class_name HoverGrabber

# ==============================================================================
@export var anim_duration := 0.1
# ==============================================================================

func hover() -> void:
	create_tween().tween_property(control, "modulate:a", 1.0, anim_duration)


func unhover() -> void:
	if is_inside_tree():
		create_tween().tween_property(control, "modulate:a", 0.0, anim_duration)
