extends Label
class_name StagePowerLabel

# ==============================================================================
@export var stage_instance: StageInstance = null :
	get:
		if stage_instance == null:
			return StageScene.get_instance().stage_instance
		return stage_instance
# ==============================================================================

func _ready() -> void:
	stage_instance.get_stage().changed.connect(_update)
	_update()


func _update() -> void:
	text = str(stage_instance.get_stage().min_power) + "-" + str(stage_instance.get_stage().max_power)
