extends QuestGenerationSequenceBase
class_name QuestGenerationSpecialStage

# ==============================================================================
@export var special_stages: Array[SpecialStageTemplate] = []
# ==============================================================================

func _generate(_stage_list: Array[StageTemplateBase]) -> Array[StageTemplateBase]:
	return [special_stages.pick_random()]
