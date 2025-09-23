extends Label
class_name StageTimerLabel

# ==============================================================================
@export var stage_instance: StageInstance = null :
	get:
		if stage_instance == null:
			return StageScene.get_instance().stage_instance
		return stage_instance
# ==============================================================================

func _process(_delta: float) -> void:
	text = str(stage_instance.get_time())
 
