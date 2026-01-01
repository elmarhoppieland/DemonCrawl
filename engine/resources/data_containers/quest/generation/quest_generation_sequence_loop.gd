extends QuestGenerationSequenceBase
class_name QuestGenerationSequenceLoop

# ==============================================================================
## The [QuestGenerationSequenceBase] to be performed in a loop.
@export var loop: Array[QuestGenerationSequenceBase] = []
# ==============================================================================

func _generate(stage_list: Array[StageTemplateBase]) -> Array[StageTemplateBase]:
	var list: Array[StageTemplateBase] = []
	
	var loop_stages: Array[StageTemplateBase] = []
	loop_stages.assign(stage_list)
	
	var i := 0
	while not loop_stages.is_empty():
		list.append_array(loop[i].generate(loop_stages))
		loop_stages.assign(stage_list.filter(func(stage: StageTemplateBase) -> bool: return stage not in list))
		i = (i + 1) % loop.size()
	
	return list
