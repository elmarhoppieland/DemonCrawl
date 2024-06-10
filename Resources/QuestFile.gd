extends ConfigFile
class_name QuestFile

# ==============================================================================

func pack() -> QuestBase:
	var base := QuestBase.new()
	base.name = get_name()
	base.lore = get_lore()
	base.icon = get_icon_name()
	base.difficulties = get_difficulties()
	
	for i in get_stage_count():
		base.stages.append(get_stage(i))
	
	return base


func get_name() -> String:
	return get_value("General", "name")


func get_lore() -> String:
	return get_value("General", "lore")


func get_icon_name() -> String:
	return get_value("General", "icon")


func create_icon() -> AtlasTexture:
	return AssetManager.get_icon(get_icon_name())


func get_difficulties() -> PackedInt32Array:
	return get_value("General", "difficulties")


func get_stages() -> PackedStringArray:
	var stages := PackedStringArray()
	
	for section in get_sections():
		if not section.match("Stage-*"):
			continue
		stages.append(get_value(section, "name"))
	
	return stages


func get_stage_count() -> int:
	var count := 0
	for section in get_sections():
		if section.match("Stage-*"):
			count += 1
	return count


func get_stage(idx: int) -> StageBase:
	var section := "Stage-%d" % idx
	
	if not has_section(section):
		return null
	
	var stage := StageBase.new()
	
	for key in get_section_keys(section):
		var value = get_value(section, key)
		if value is Array:
			stage[key].assign(value)
		else:
			stage[key] = value
	
	return stage


class StageBase extends RefCounted:
	var name := ""
	var min_power: Array[int] = []
	var max_power: Array[int] = []
	var monsters: Array[int] = []
	var size: Array[int] = []
	
	
	func generate(rng: RandomNumberGenerator) -> Stage:
		return Stage.generate(self, rng)


class QuestBase extends RefCounted:
	var name := ""
	var lore := ""
	var icon := ""
	var difficulties: PackedInt32Array = []
	
	var stages: Array[QuestFile.StageBase] = []
	
	
	func generate(rng: RandomNumberGenerator) -> void:
		Quest.quest_name = name
		Quest.stages = []
		
		var stage_index := 0
		while true:
			var length := rng.randi() % 2 + rng.randi() % 2 + 1
			if stage_index == 0 and length > 2:
				continue
			
			for i in length:
				var stage := stages[stage_index].generate(rng)
				stage.locked = true
				Quest.stages.append(stage)
				stage_index += 1
				if stage_index >= stages.size():
					Quest.stages[0].locked = false
					return
			
			var special_stage := generate_random_special_stage(rng)
			special_stage.locked = true
			Quest.stages.append(special_stage)
	
	func generate_random_special_stage(rng: RandomNumberGenerator) -> SpecialStage:
		const DIR := "res://Assets/special_stages/"
		var files := DirAccess.get_files_at(DIR)
		var file := files[rng.randi() % files.size()]
		return ResourceLoader.load(DIR.path_join(file)).new()
