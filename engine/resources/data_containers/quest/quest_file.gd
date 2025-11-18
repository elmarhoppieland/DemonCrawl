extends Resource
class_name QuestFile

# ==============================================================================
@export var name := ""  ## The name of the quest.
@export_multiline var lore := ""  ## The quest's lore.
@export var token_shop_purchase: TokenShopItemBase = null  ## The [TokenShopItem] that must be purchased to unlock this quest, or [code]null[/code] if this quest does not need to be purchased.
@export var icon: Texture2D = null  ## The quest's icon.
@export var skip_unlock := false  ## If this is [code]true[/code], unlocking this quest should also unlock the next quest.

@export var stage_list: Array[StageFileBase] = []  ## The order that the stages should appear in the quest. Special stages will be inserted in-between these stages.

@export var generation_sequence: QuestGenerationSequenceBase
# ==============================================================================

func generate() -> Quest:
	var quest := Quest.new()
	quest.source_file = self
	if Codex.selected_mastery:
		var selected_mastery := Codex.selected_mastery
		var level := Codex.get_selectable_mastery_level(selected_mastery)
		quest.equip_mastery(selected_mastery.create(level))
	
	var stages := generation_sequence.generate(stage_list)
	for i in stages.size():
		var stage := stages[i].generate()
		#stage.locked = i > 0
		quest.add_stage(stage)
	
	return quest
