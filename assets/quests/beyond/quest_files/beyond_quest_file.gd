@tool
extends QuestFile
class_name BeyondQuestFile

# ==============================================================================

func _validate_property(property: Dictionary) -> void:
	if property.name in ["lore", "token_shop_purchase", "icon", "skip_unlock"]:
		property.usage &= ~PROPERTY_USAGE_DEFAULT


func generate(artifacts: Array[StageFile] = []) -> Quest:
	if artifacts.size() != stage_list.size():
		Debug.log_error("Could not generate quest: The number of used artifacts (%d) does not match the stage count (%d)." % [artifacts.size(), stage_list.size()])
		return null
	
	var quest_stage_list: Array[StageTemplateBase] = []
	for i in stage_list.size():
		var template := stage_list[i].duplicate()
		if template is StageTemplate:
			template.file = artifacts[i]
		else:
			Debug.log_error("Could not insert selected stage (at index %d) into the quest, as the stage template used is not supported." % i)
		
		quest_stage_list.append(template)
	
	return _generate(quest_stage_list)
