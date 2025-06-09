extends Label
class_name StageMonsterCountLabel

# ==============================================================================

func _process(_delta: float) -> void:
	text = str(StageInstance.get_current().get_remaining_monster_count())
