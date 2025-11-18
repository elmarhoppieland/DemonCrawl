extends QuestGenerationSequenceBase
class_name QuestGenerationSequenceArray

# ==============================================================================
@export var generation_sequence: Array[QuestGenerationSequenceBase] = []
# ==============================================================================

func _generate(stage_list: Array[StageFileBase]) -> Array[StageFileBase]:
	var list: Array[StageFileBase] = []
	stage_list = stage_list.duplicate()
	for sequence in generation_sequence:
		list.append_array(sequence.generate(stage_list))
		stage_list.assign(stage_list.filter(func(stage: StageFileBase) -> bool: return stage not in list))
	return list
