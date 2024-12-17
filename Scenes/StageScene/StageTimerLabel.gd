extends Label
class_name StageTimerLabel

# ==============================================================================

func _process(_delta: float) -> void:
	text = str(Stage.get_current().get_instance().get_time())
