extends StaticClass
class_name StageModDB

# ==============================================================================
const BASE_DIR := "res://Assets/mods/"
# ==============================================================================

## Returns an [StageModData] [Resource] for all mods in the database.
static func get_mods_data() -> Array[StageModData]:
	var mods: Array[StageModData] = []
	for file in DirAccess.get_files_at(BASE_DIR):
		file = file.trim_suffix(".remap") # for exported builds
		if file.get_extension() != "tres":
			continue
		mods.append(ResourceLoader.load(BASE_DIR.path_join(file)))
	return mods


## Creates a new [StageModDB.ModFilter]. Use it to generate random mods based on certain filters.
static func create_filter() -> ModFilter:
	return ModFilter.new()


## Filters mods in the database.
class ModFilter:
	var _min_difficulty := (1 << 63)
	var _max_difficulty := (1 << 63) - 1
	var _rng: RandomNumberGenerator
	
	## Only allow mods with a difficulty of [code]max_difficulty[/code] or less.
	func set_max_difficulty(max_difficulty: int) -> ModFilter:
		_max_difficulty = max_difficulty
		return self
	
	## Only allow mods with a difficulty of [code]min_difficulty[/code] or higher.
	func set_min_difficulty(min_difficulty: int) -> ModFilter:
		_min_difficulty = min_difficulty
		return self
	
	## Only allow mods with a difficulty of exactly [code]difficulty[/code].
	func set_difficulty(difficulty: int) -> ModFilter:
		_max_difficulty = difficulty
		_min_difficulty = difficulty
		return self
	
	## Sets the [RandomNumberGenerator] used for randomizing.
	func set_rng(rng: RandomNumberGenerator) -> ModFilter:
		_rng = rng
		return self
	
	## Returns a random mod that matches this filter.
	func get_random_mod() -> StageMod:
		var options := get_mods_data()
		if options.is_empty():
			Debug.log_error("Could not find any mods with filter %s." % self)
			return null
		
		return options[RNG.randi(_rng) % options.size()].get_mod_script().new()
	
	## Returns all mods that match this filter.
	func get_mods_data() -> Array[StageModData]:
		return Array(StageModDB.get_mods_data().filter(matches), TYPE_OBJECT, &"Resource", StageModData)
	
	## Returns [code]true[/code] if no mods match this filter.
	func is_empty() -> bool:
		return not StageModDB.get_mods_data().any(matches)
	
	## Returns whether the given [code]data[/code] matches this filter.
	func matches(data: StageModData) -> bool:
		if data.difficulty > _max_difficulty:
			return false
		if data.difficulty < _min_difficulty:
			return false
		
		return true
	
	func _to_string() -> String:
		return "<StageModDB.ModFilter(%s)>" % ", ".join(get_property_list()\
			.filter(func(prop: Dictionary): return prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and prop.class_name.is_empty())\
			.map(func(prop: Dictionary): return "%s: %s" % [prop.name.capitalize(), get(prop.name)])
		)
