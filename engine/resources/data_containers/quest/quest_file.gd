extends Resource
class_name QuestFile

# ==============================================================================
@export var name := ""  ## The name of the quest.
@export_multiline var lore := ""  ## The quest's lore.
@export var token_shop_purchase: TokenShopItemBase = null  ## The [TokenShopItem] that must be purchased to unlock this quest, or [code]null[/code] if this quest does not need to be purchased.
@export var icon: Texture2D = null  ## The quest's icon.
@export var skip_unlock := false  ## If this is [code]true[/code], unlocking this quest should also unlock the next quest.
@export var stages: Array[StageFile] = []  ## The stages in the quest.
@export var special_stages: Array[SpecialStageFile] = []  ## The special stages that may appear in the quest.
# ==============================================================================

func generate() -> Quest:
	var quest := Quest.new()
	quest.source_file = self
	if Codex.selected_mastery:
		var selected_mastery := Codex.selected_mastery
		var level := Codex.get_selectable_mastery_level(selected_mastery)
		quest.equip_mastery(selected_mastery.create(level))
	
	var stage_index := 0
	while true:
		var length := randi() % 2 + randi() % 2 + 1
		if stage_index == 0 and length > 2:
			continue
		
		for i in length:
			var stage := stages[stage_index].generate()
			stage.locked = stage_index > 0
			quest.add_stage(stage)
			stage_index += 1
			if stage_index >= stages.size():
				return quest
		
		var special_stage := generate_random_special_stage()
		if special_stage != null:
			special_stage.locked = true
			quest.add_stage(special_stage)
	
	return null


func generate_random_special_stage() -> SpecialStage:
	if special_stages.is_empty():
		return null
	return special_stages.pick_random().create()
