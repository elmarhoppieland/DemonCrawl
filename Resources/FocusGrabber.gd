extends Grabber
class_name FocusGrabber

# ==============================================================================

func interact() -> void:
	Focus.move_to(control)


func disable() -> void:
	if Focus._focus == control:
		Focus.hide()
