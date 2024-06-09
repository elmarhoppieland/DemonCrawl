extends ConfigFile
class_name DifficultyFile

# ==============================================================================
var quests: Array[QuestFile] = []
# ==============================================================================

func open_quests() -> Array[QuestFile]:
	if not quests.is_empty():
		return quests
	
	for quest in get_quests():
		quests.append(QuestFile.new())
		quests[-1].load(quest)
	
	return quests


func get_name() -> String:
	return get_value("General", "name", "UNSET_DIFFICULTY_NAME")


func get_quests() -> PackedStringArray:
	return get_value("General", "quests", [])


func requires_token_shop_purchase() -> bool:
	return get_value("General", "token_shop_purchase", false)


func get_icon_path() -> String:
	return get_value("General", "icon", "difficulty_casual")


func get_icon() -> Icon:
	return AssetManager.get_icon(get_icon_path())


func get_starting_lives() -> int:
	return get_value("General", "starting_lives", 5)


func get_conditions() -> PackedStringArray:
	return get_value("General", "conditions", [])


func is_unlocked() -> bool:
	for condition in get_conditions():
		if condition.begins_with("!") == PlayerFlags.has_flag(condition.trim_prefix("!")):
			return false
	
	return true


func get_initial_unlocks() -> int:
	return get_value("General", "initial_unlocks", 1)
