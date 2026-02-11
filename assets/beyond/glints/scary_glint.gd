extends Glint

# ==============================================================================

func _quest_start() -> void:
	for stage in get_quest().get_stages():
		if stage is Stage:
			stage.monsters -= 10
