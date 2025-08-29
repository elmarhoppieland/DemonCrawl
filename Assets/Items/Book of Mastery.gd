@tool
extends Book

# ==============================================================================

func _activate() -> void:
	if get_quest().has_mastery():
		get_quest().get_mastery().gain_charge()
