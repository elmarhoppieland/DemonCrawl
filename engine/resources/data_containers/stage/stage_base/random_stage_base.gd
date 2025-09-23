@tool
extends StageBase
class_name RandomStageBase

# ==============================================================================
static var stage_list := DirAccess.get_directories_at("res://assets/skins/")
# ==============================================================================

func generate() -> Stage:
	var stage := super()
	stage.name = stage_list[randi() % stage_list.size()]
	return stage


func _validate_property(property: Dictionary) -> void:
	if property.name == &"name":
		property.usage &= ~PROPERTY_USAGE_DEFAULT
