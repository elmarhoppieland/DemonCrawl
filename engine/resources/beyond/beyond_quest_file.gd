@tool
extends QuestFile
class_name BeyondQuestFile

# ==============================================================================

func _validate_property(property: Dictionary) -> void:
	if property.name in ["lore", "token_shop_purchase", "icon", "skip_unlock"]:
		property.usage &= ~PROPERTY_USAGE_DEFAULT


func generate(artifacts: Array[StageFile] = [], emblem_data: EmblemData = null, glint_data: GlintData = null) -> Quest:
	var quest_stage_list: Array[StageTemplateBase] = stage_list.duplicate()
	
	for template in quest_stage_list:
		if template is BeyondStageTemplate:
			template.set_stage_from_list(artifacts)
	
	var emblem: Emblem = null
	if emblem_data:
		emblem = emblem_data.create()
		
		quest_stage_list = emblem.parse_stage_list(artifacts, quest_stage_list)
	
	var quest := _generate(quest_stage_list)
	
	if emblem:
		quest.add_child(emblem)
	
	if glint_data:
		quest.add_child(glint_data.create())
	
	return quest
