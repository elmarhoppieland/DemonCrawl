@tool
extends StageFileBase
class_name SpecialStageFile

# ==============================================================================
@export var name := ""
@export var special_script: Script = null
# ==============================================================================

func _generate() -> SpecialStage:
	return special_script.new(name)
