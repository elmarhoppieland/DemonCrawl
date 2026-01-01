@tool
extends StageTemplate
class_name RandomStageTemplate

# ==============================================================================
# TODO: filter this list (maybe add it to the register?)
# (we don't want stages like the metagate or wester showing up here)
static var stage_list := DirAccess.get_directories_at("res://assets/skins/")
# ==============================================================================

func _generate() -> Stage:
	var stage := super()
	var stage_name := stage_list[randi() % stage_list.size()]
	stage.file = load("res://assets/skins/%s/%s" % [stage_name, stage_name])
	return stage


func _validate_property(property: Dictionary) -> void:
	if property.name == &"file":
		property.usage &= ~PROPERTY_USAGE_DEFAULT
