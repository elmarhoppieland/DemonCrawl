@tool
extends Mastery
class_name Banker

# ==============================================================================

func _enable() -> void:
	get_quest().get_stage_effects().get_object_value.connect(_get_object_value)


func _disable() -> void:
	get_quest().get_stage_effects().get_object_value.disconnect(_get_object_value)


func _quest_start() -> void:
	get_stats().coins += 15


func _get_object_value(object: CellObject, value: int, value_name: StringName) -> int:
	if object is not TreasureChest:
		return value
	if value_name != &"coins":
		return value
	if level < 2:
		return value
	return 2 * value


func _ability() -> void:
	get_stats().coins *= 2
