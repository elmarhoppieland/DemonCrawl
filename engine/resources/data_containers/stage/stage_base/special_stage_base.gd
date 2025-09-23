@tool
extends Resource
class_name SpecialStageBase

# ==============================================================================
@export var name := ""
@export var special_script: Script = null
# ==============================================================================

func create() -> SpecialStage:
	return special_script.new(name)
