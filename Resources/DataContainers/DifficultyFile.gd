extends ConfigFile
class_name DifficultyFile

# ==============================================================================
var quests: Array[QuestFile] = []
# ==============================================================================

func apply_starting_values() -> void:
	if not has_section("Values"):
		return
	
	for key in get_section_keys("Values"):
		var origin := Quest.get_current()
		while "/" in key:
			if key.get_slice("/", 0) not in origin:
				Debug.log_error("Property '%s' not found in base '%s'." % [key.get_slice("/", 0), UserClassDB.script_get_identifier(origin.get_script())])
				break
			
			origin = origin[key.get_slice("/", 0)]
			key = key.substr(key.find("/") + 1)
		
		origin.set(key, get_value("Values", key))


func open_quests() -> Array[QuestFile]:
	if not quests.is_empty():
		return quests
	
	for quest in get_quests():
		var file := QuestFile.new()
		file.load(quest)
		quests.append(file)
	
	return quests


func get_name() -> String:
	return get_value("General", "name", "UNSET_DIFFICULTY_NAME")


func get_quests() -> PackedStringArray:
	return get_value("General", "quests", [])


func requires_token_shop_purchase() -> bool:
	return get_value("General", "token_shop_purchase", false)


func get_icon_path() -> String:
	return get_value("General", "icon", "difficulty_casual")


func get_icon() -> Texture2D:
	return IconManager.get_icon_data(get_icon_path()).create_texture()


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
