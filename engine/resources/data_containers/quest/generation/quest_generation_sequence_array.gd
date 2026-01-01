extends QuestGenerationSequenceBase
class_name QuestGenerationSequenceArray

# ==============================================================================
@export var generation_sequence: Array[QuestGenerationSequenceBase] = []
# ==============================================================================

func _generate(stage_list: Array[StageTemplateBase]) -> Array[StageTemplateBase]:
	var list: Array[StageTemplateBase] = []
	stage_list = stage_list.duplicate()
	for sequence in generation_sequence:
		list.append_array(sequence.generate(stage_list))
		stage_list.assign(stage_list.filter(func(stage: StageTemplateBase) -> bool: return stage not in list))
	return list
