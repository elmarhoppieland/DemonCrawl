@tool
extends MagicItem

# ==============================================================================

func _use() -> void:
	get_quest().get_selected_stage().monsters -= 5


func _can_use() -> bool:
	return super() and get_tree().current_scene is StageSelect


func _invoke() -> void:
	get_quest().stages.pick_random().monsters -= 5
