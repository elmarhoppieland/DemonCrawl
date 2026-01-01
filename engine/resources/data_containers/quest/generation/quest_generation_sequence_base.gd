@abstract
extends Resource
class_name QuestGenerationSequenceBase

# ==============================================================================

## Generates the stage sequence by adding some of given stages in the [param stage_list]
## to the generated stages.
func generate(stage_list: Array[StageTemplateBase]) -> Array[StageTemplateBase]:
	return _generate(stage_list)


## Virtual method. Should generate the stage sequence by adding some of given
## stages in the [param stage_list] to the [param generated_stages].
@abstract func _generate(stage_list: Array[StageTemplateBase]) -> Array[StageTemplateBase]
