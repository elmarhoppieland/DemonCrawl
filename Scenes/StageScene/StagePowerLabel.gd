extends Label
class_name StagePowerLabel

# ==============================================================================

func _process(_delta: float) -> void:
	text = str(Stage.get_current().min_power) + "-" + str(Stage.get_current().max_power)
