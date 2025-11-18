extends QuestGenerationSequenceBase
class_name QuestGenerationSpecialStage

# ==============================================================================
@export var special_stages: Array[SpecialStageFile] = []
# ==============================================================================

func _generate(_stage_list: Array[StageFileBase]) -> Array[StageFileBase]:
	return [special_stages.pick_random()]
