extends DifficultyBase
class_name BeyondDifficulty

# ==============================================================================
@export var name := ""  ## The name of the difficulty.
@export var icon: Texture2D = null  ## The icon of the difficulty.

@export var conditions: Array[Condition] = [] ## The conditions for this difficulty to be visible. If empty, this difficulty is always visible.

@export var guaranteed_chests := 1 ## The number of guaranteed chests per stage.

## The quest files to use for quests generated in this difficulty. Each index
## specifies the quest file to use for emblems of that level.
## [br][br][b]Note:[/b] Some emblems (like Mythic Emblems) may specify a different
## quest file to use. In that case, that one will override this one.
@export var quest_files: Array[BeyondQuestFile] = []

@export_group("Starting Stats")
@export var max_life := 5  ## The amount of max lives the player should start each quest with.
@export var life := 5  ## The amount of lives the player should start each quest with. Should never be higher than [property max_life].
@export var revives := 0  ## The number of revives the player should start each quest with.
@export var defense := 0  ## The amount of defense the player should start each quest with.
@export var coins := 0  ## The amount of coins the player should start each quest with.
# ==============================================================================
var _quest_selection: BeyondQuestSelection
var _quest_details: BeyondQuestDetails
# ==============================================================================

func _get_name_id() -> String:
	return "difficulty.beyond"


func _get_icon() -> Texture2D:
	return icon


func _get_quest_selection_node() -> Node:
	_quest_selection = load("res://assets/quests/beyond/beyond_quest_selection.tscn").instantiate()
	_quest_selection.artifact_erased.connect(func(stage: StageFile) -> void:
		_quest_details.return_artifact(stage)
		hide_begin_button()
	)
	return _quest_selection


func _get_quest_details_node() -> Node:
	_quest_details = load("res://assets/quests/beyond/beyond_quest_details.tscn").instantiate()
	_quest_details.artifact_selected.connect(func(stage: StageFile) -> void:
		_quest_selection.insert_artifact(stage)
		if _quest_selection.can_generate_quest():
			show_begin_button()
		else:
			hide_begin_button()
	)
	return _quest_details


func _begin_selected_quest() -> Quest:
	var artifacts := _quest_selection.get_artifacts()
	var emblem_level := 0 # TODO: apply emblem level
	
	var source_quest := quest_files[emblem_level]
	
	for artifact in artifacts:
		Codex.lose_artifact(artifact) # TODO: use cost from emblem
	
	var quest := source_quest.generate(artifacts)
	
	# TODO: apply emblem effects
	
	return quest


func _apply_starting_values(quest: Quest) -> void:
	quest.get_stats().max_life = max_life
	quest.get_stats().life = life
	quest.get_stats().revives = revives
	quest.get_stats().defense = defense
	quest.get_stats().coins = coins
	
	# TODO: apply glint effects


func _select_quest_index(quest_index: int) -> void:
	if not _quest_selection:
		return
	
	_quest_selection.select_slot(quest_index)
	
	if not _quest_selection.can_generate_quest():
		hide_begin_button()


func _is_unlocked() -> bool:
	for condition in conditions:
		if not condition.is_met():
			return false
	
	return true


func _parse_guaranteed_objects(guaranteed_objects: Array[CellObject]) -> Array[CellObject]:
	for i in guaranteed_chests:
		var chest := TreasureChest.new()
		guaranteed_objects.append(chest)
	return guaranteed_objects
