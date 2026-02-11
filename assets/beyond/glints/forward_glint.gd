extends Glint

# ==============================================================================

func _quest_start() -> void:
	get_quest().get_attributes().cells_opened_since_mistake += 50
	get_quest().get_attributes().omens_destroyed += 3
	get_quest().get_attributes().chests_opened += 3
