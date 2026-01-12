@abstract
class_name QuestsManager

# ==============================================================================
enum QuestState {
	INVALID = -1,
	COMPLETED,
	UNLOCKED,
	LOCKED_COMPLETE_PREVIOUS,
	LOCKED_NEEDS_PURCHASE
}
# ==============================================================================
static var selected_quest_index: int = Eternal.create(0)
static var selected_difficulty: DifficultyBase = Eternal.create(load("res://assets/quests/casual/casual.tres"))

static var quest_completions: Array[QuestCompletionData] = Eternal.create([] as Array[QuestCompletionData])
# ==============================================================================

static func get_difficulties() -> Array[DifficultyBase]:
	return DemonCrawl.get_full_registry().difficulties


static func change_difficulty(direction: int) -> void:
	var unlocked_difficulties := get_unlocked_difficulties()
	var idx := wrapi(unlocked_difficulties.find(selected_difficulty) + direction, 0, unlocked_difficulties.size())
	selected_difficulty = unlocked_difficulties[idx]


static func get_unlocked_difficulties() -> Array[DifficultyBase]:
	var unlocked_difficulties: Array[DifficultyBase] = []
	for difficulty in get_difficulties():
		if difficulty.is_unlocked():
			unlocked_difficulties.append(difficulty)
	return unlocked_difficulties


static func is_completed(quest: QuestFile) -> bool:
	return get_completion_data(quest).completion_count > 0


static func get_completion_data(quest: QuestFile) -> QuestCompletionData:
	for data in quest_completions:
		if data.quest == quest:
			return data
	
	var data := QuestCompletionData.new()
	data.quest = quest
	return data


static func get_quest_state(quest: QuestFile, difficulty: Difficulty = selected_difficulty) -> QuestState:
	var quest_index := difficulty.quests.find(quest)
	if quest_index < 0:
		return QuestState.INVALID
	
	for i in quest_index:
		var previous_quest := difficulty.quests[i]
		if previous_quest.skip_unlock:
			continue
		if QuestsManager.get_completion_data(previous_quest).completion_count > 0:
			continue
		return QuestState.LOCKED_COMPLETE_PREVIOUS
	
	if quest.token_shop_purchase != null:
		return QuestState.LOCKED_NEEDS_PURCHASE
	
	var data := get_completion_data(quest)
	if data.completion_count > 0:
		return QuestState.COMPLETED
	return QuestState.UNLOCKED


class QuestCompletionData extends Resource:
	@export var quest: QuestFile = null
	@export var completion_count := 0
	@export var best_score := 0
	
	func save() -> void:
		if self not in QuestsManager.quest_completions:
			QuestsManager.quest_completions.append(self)
