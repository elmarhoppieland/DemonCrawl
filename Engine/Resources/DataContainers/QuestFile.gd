extends Resource
class_name QuestFile

# ==============================================================================
@export var name := ""  ## The name of the quest.
@export_multiline var lore := ""  ## The quest's lore.
@export var icon: Texture2D = null  ## The quest's icon.
@export var skip_unlock := false  ## If this is [code]true[/code], unlocking this quest should also unlock the next quest.
@export var stages: Array[StageBase] = []  ## The stages in the quest.
@export var special_stages: Array[SpecialStageBase] = []  ## The special stages that may appear in the quest.
# ==============================================================================

func generate() -> Quest:
	var quest := Quest.new()
	
	quest.name = name
	
	var stage_index := 0
	while true:
		var length := randi() % 2 + randi() % 2 + 1
		if stage_index == 0 and length > 2:
			continue
		
		for i in length:
			var stage := stages[stage_index].generate()
			stage.locked = true
			quest.stages.append(stage)
			stage_index += 1
			if stage_index >= stages.size():
				quest.stages[0].locked = false
				return quest
		
		var special_stage := generate_random_special_stage()
		if special_stage != null:
			special_stage.locked = true
			quest.stages.append(special_stage)
	
	return null


func generate_random_special_stage() -> SpecialStage:
	if special_stages.is_empty():
		return null
	return special_stages.pick_random().create()
