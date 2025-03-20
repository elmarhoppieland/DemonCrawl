@tool
extends Item

# ==============================================================================

func _use() -> void:
	Quest.get_current().get_selected_stage().monsters -= 5


func _can_use() -> bool:
	return get_tree().current_scene is StageSelect


func _invoke() -> void:
	Quest.get_current().stages.pick_random().monsters -= 5
