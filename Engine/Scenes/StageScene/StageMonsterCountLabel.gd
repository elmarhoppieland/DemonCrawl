extends Label
class_name StageMonsterCountLabel

# ==============================================================================

func _process(_delta: float) -> void:
	text = str(Stage.get_current().get_instance().get_remaining_monster_count())
