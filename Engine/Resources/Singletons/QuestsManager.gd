extends StaticClass
class_name QuestsManager

# ==============================================================================
static var selected_quest: QuestFile = Eternal.create(preload("res://Assets/Quests/Casual/Tutorial.tres"))
static var selected_difficulty: Difficulty = Eternal.create(preload("res://Assets/Quests/Casual/Casual.tres"))

static var difficulties: Array[Difficulty] = []

static var quest_completions: Array[QuestCompletionData] = Eternal.create([] as Array[QuestCompletionData])
# ==============================================================================

static func _static_init() -> void:
	find_difficulties("res://Assets/Quests/")


static func find_difficulties(directory: String) -> void:
	var dirs := PackedStringArray([directory])
	while not dirs.is_empty():
		var dir := dirs[-1]
		dirs.resize(dirs.size() - 1)
		for subdir in DirAccess.get_directories_at(dir):
			dirs.append(dir.path_join(subdir))
		if ResourceLoader.exists(dir):
			var resource := load(dir)
			if resource is Difficulty:
				difficulties.append(resource)


static func change_difficulty(direction: int) -> void:
	var unlocked_difficulties := get_unlocked_difficulties()
	var idx := wrapi(unlocked_difficulties.find(selected_difficulty) + direction, 0, unlocked_difficulties.size())
	selected_difficulty = unlocked_difficulties[idx]


static func get_unlocked_difficulties() -> Array[Difficulty]:
	var unlocked_difficulties: Array[Difficulty] = []
	for difficulty in difficulties:
		if difficulty.is_unlocked():
			unlocked_difficulties.append(difficulty.difficulty)
	return unlocked_difficulties


static func get_completion_data(quest: QuestFile) -> QuestCompletionData:
	for data in quest_completions:
		if data.quest == quest:
			return data
	
	var data := QuestCompletionData.new()
	data.quest = quest
	return data


static func is_quest_unlocked(quest: QuestFile, difficulty: Difficulty = selected_difficulty) -> bool:
	var quest_index := selected_difficulty.quests.find(quest)
	if quest_index < 0:
		Debug.log_error("The provided quest (%s) is not a part of the provided difficulty (%s)." % [quest.name, difficulty.name])
		return false
	
	if quest_index == 0:
		return true
	
	for i in quest_index:
		var previous_quest := selected_difficulty.quests[i]
		if previous_quest.skip_unlock:
			continue
		if QuestsManager.get_completion_data(previous_quest).completion_count > 0:
			continue
		return false
	
	if QuestsManager.selected_difficulty.token_shop_purchase:
		return TokenShop.is_item_purchased("TOKEN_SHOP_UPGRADE_QUEST_" + str(quest_index + 1))
	return true


class QuestCompletionData extends Resource:
	@export var quest: QuestFile = null
	@export var completion_count := 0
	@export var best_score := 0
