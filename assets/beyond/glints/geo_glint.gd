extends Glint

# ==============================================================================

func _quest_start() -> void:
	get_quest().get_attributes().pathfinding += 5
