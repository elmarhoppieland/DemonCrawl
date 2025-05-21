extends Grabber
class_name FocusGrabber

# ==============================================================================

func interact() -> void:
	Focus.move_to(control)


func disable() -> void:
	if Focus.get_focused_node() == control:
		Focus.get_instance().hide()
