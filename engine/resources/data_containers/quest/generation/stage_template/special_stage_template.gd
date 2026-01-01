@tool
extends StageTemplateBase
class_name SpecialStageTemplate

# ==============================================================================
@export var name := ""
@export var special_script: Script = null
# ==============================================================================

func _generate() -> SpecialStage:
	return special_script.new(name)
