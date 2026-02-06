extends Glint

# ==============================================================================

func _enable() -> void:
	for stage in get_quest().get_stages():
		if stage is Stage:
			stage.min_power -= 1
			stage.max_power -= 1
