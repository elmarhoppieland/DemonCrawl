extends DifficultyBase
class_name BeyondDifficulty

# ==============================================================================
const BEYOND_COLOR := Color(0.596, 0.008, 0.875, 1.0)
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


func _get_color() -> Color:
	return BEYOND_COLOR


func _get_quest_selection_node() -> Node:
	_quest_selection = load("res://engine/resources/beyond/beyond_quest_selection.tscn").instantiate()
	_quest_selection.artifact_erased.connect(func(stage: StageFile) -> void:
		var used_artifacts := 0
		for artifact in _quest_selection.get_artifacts():
			if artifact == stage:
				used_artifacts += 1
		
		var emblem := _quest_selection.get_emblem()
		var artifact_cost := emblem.artifact_cost if emblem else 1
		var used_artifact_count := used_artifacts * artifact_cost
		
		_quest_details.set_artifact_count(stage, Codex.get_artifacts(stage) - used_artifact_count)
		
		hide_begin_button()
	)
	_quest_selection.emblem_erased.connect(func(emblem: EmblemData) -> void:
		var artifacts: Dictionary[StageFile, int] = {}
		for artifact in _quest_selection.get_artifacts():
			if artifact != null:
				artifacts[artifact] = artifacts.get(artifact, 0) + 1
		
		for artifact in artifacts:
			_quest_details.set_artifact_count(artifact, Codex.get_artifacts(artifact) - artifacts[artifact])
		
		_quest_details.return_emblem(emblem)
	)
	_quest_selection.artifact_slot_selected.connect(func(_slot_idx: int) -> void:
		_quest_details.show_artifacts()
	)
	_quest_selection.emblem_slot_selected.connect(func() -> void:
		_quest_details.show_emblems()
	)
	return _quest_selection


func _get_quest_details_node() -> Node:
	_quest_details = load("res://engine/resources/beyond/beyond_quest_details.tscn").instantiate()
	_quest_details.artifact_selected.connect(func(stage: StageFile) -> void:
		_quest_selection.insert_artifact(stage)
		
		var used_artifacts := 0
		for artifact in _quest_selection.get_artifacts():
			if artifact == stage:
				used_artifacts += 1
		
		var emblem := _quest_selection.get_emblem()
		var artifact_cost := emblem.artifact_cost if emblem else 1
		var used_artifact_count := used_artifacts * artifact_cost
		
		_quest_details.set_artifact_count(stage, Codex.get_artifacts(stage) - used_artifact_count)
		
		if _quest_selection.can_generate_quest():
			show_begin_button()
		else:
			hide_begin_button()
	)
	_quest_details.emblem_selected.connect(func(emblem: EmblemData) -> void:
		_quest_selection.insert_emblem(emblem)
		if _quest_selection.can_generate_quest():
			show_begin_button()
		else:
			hide_begin_button()
	)
	return _quest_details


func _begin_selected_quest() -> Quest:
	var artifacts := _quest_selection.get_artifacts()
	var emblem := _quest_selection.get_emblem()
	
	var source_quest := quest_files[emblem.level]
	
	for artifact in artifacts:
		Codex.lose_artifact(artifact, emblem.artifact_cost)
	
	return source_quest.generate(artifacts, emblem)


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
