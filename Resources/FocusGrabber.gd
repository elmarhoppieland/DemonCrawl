extends Grabber
class_name FocusGrabber

# ==============================================================================

func interact() -> void:
	Focus.move_to(control)
