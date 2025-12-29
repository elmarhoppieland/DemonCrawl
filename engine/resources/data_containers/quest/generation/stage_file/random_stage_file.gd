@tool
extends StageFile
class_name RandomStageFile

# ==============================================================================
# TODO: filter this list (maybe add it to the register?)
# (we don't want stages like the metagate or wester showing up here)
static var stage_list := DirAccess.get_directories_at("res://assets/skins/")
# ==============================================================================

func _generate() -> Stage:
	var stage := super()
	stage.name_id = "stage." + stage_list[randi() % stage_list.size()]
	return stage


func _validate_property(property: Dictionary) -> void:
	if property.name == &"name":
		property.usage &= ~PROPERTY_USAGE_DEFAULT
