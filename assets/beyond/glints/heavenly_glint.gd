extends Glint

# ==============================================================================

func _quest_start() -> void:
	get_quest().get_stats().revives += 1
