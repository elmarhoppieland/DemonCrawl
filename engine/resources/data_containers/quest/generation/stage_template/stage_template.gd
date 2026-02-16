@tool
extends StageTemplateDefaultBase
class_name StageTemplate

# ==============================================================================
@export var file: StageFileBase
# ==============================================================================

func _generate() -> Stage:
	return Stage.new(file)
