extends Glint

# ==============================================================================

func _quest_start() -> void:
	var stage: Stage = null
	for i in get_quest().get_stages():
		if i is Stage:
			stage = i
			break
	
	assert(stage != null, "Quest does not contain a Stage to duplicate.")
	
	get_quest().add_stage(stage.duplicate(), 0)
