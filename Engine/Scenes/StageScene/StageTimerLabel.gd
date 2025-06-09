extends Label
class_name StageTimerLabel

# ==============================================================================

func _process(_delta: float) -> void:
	text = str(StageInstance.get_current().get_time())
