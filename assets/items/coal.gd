@tool
extends OmenItem

# ==============================================================================

func _enable() -> void:
	get_quest().get_attributes().change_property.connect(_change_attribute)


func _disable() -> void:
	get_quest().get_attributes().change_property.disconnect(_change_attribute)


func _change_attribute(attribute: StringName, value: Variant) -> Variant:
	if attribute == &"morality":
		return _change_morality(value)
	return value


func _change_morality(morality: int) -> int:
	if morality >= get_attributes().morality:
		return get_attributes().morality
	
	life_lose(1)
	return morality
