@tool
extends Resource
class_name SpecialStageFile

# ==============================================================================
@export var name := ""
@export var special_script: Script = null
# ==============================================================================

func create() -> SpecialStage:
	return special_script.new(name)
