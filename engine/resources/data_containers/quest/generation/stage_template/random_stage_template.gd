@tool
extends StageTemplate
class_name RandomStageTemplate

# ==============================================================================

func _generate() -> Stage:
	var stage := super()
	stage.file = DemonCrawl.get_full_registry().stages.pick_random()
	return stage


func _validate_property(property: Dictionary) -> void:
	if property.name == &"file":
		property.usage &= ~PROPERTY_USAGE_DEFAULT
