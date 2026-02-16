@tool
extends StageFileBase
class_name StageFile

# ==============================================================================
static var _monster_pools_cache: Dictionary[String, PackedStringArray] = {}
static var _monster_pools_reloading := false
static var _monster_pools_reloaded := Signal() :
	get:
		if _monster_pools_reloaded.is_null():
			(StageFile as Object).add_user_signal("__monster_pools_reloaded")
			_monster_pools_reloaded = Signal(StageFile, "__monster_pools_reloaded")
		return _monster_pools_reloaded
# ==============================================================================
@warning_ignore("unused_private_class_variable")
@export_tool_button("Autofill") var _tool_button_autofill := _autofill

@export var name := "" ## The name of the stage, as a translation [String].
@export var adjective := "" ## The adjective for this stage. This is used when it is the secondary theme of a [CombinedStageFile].
@export_multiline var description := "" ## The description for this stage. This is desplayed underneath the stage name on the overworld.

@export var bg: Texture2D ## The background texture used for this stage. This texture will also be used for the stage icon.

@export var normal := true ## If [code]true[/code], this stage may be chosen by [RandomStageTemplate] and similar classes.

@export_group("Monsters", "monster_")
@export var monster_texture: Texture2D ## The texture used for the monsters in this stage.
@export var monster_name_pool: StringTable ## The name pool used for the monsters in this stage.

@export_group("Artifact", "artifact_")
@export var artifact_texture: Texture2D ## The texture used for this stage's artifact.
@export var artifact_name := "" ## The name of this stage's artifact.
@export var artifact_name_plural := "" ## The pluralized name of this stage's artifact.

@export_group("Sounds")
@export var music: AudioStream ## The music played in this stage.
@export var ambience_a: AudioStream ## The ambience A played in this stage.
@export var ambience_b: AudioStream ## The ambience B played in this stage.

@export_group("Cell", "cell_")
@export var cell_bg: Texture2D ## The background texture used for visible cells in this stage.
@export var cell_hidden: Texture2D ## The texture used for hidden cells in this stage.
@export var cell_checking: Texture2D ## The texture used for cells in this stage that are being checked (i.e. visually pressed down).
@export var cell_flag: Texture2D ## The texture used for the flag on cells in this stage that are flagged. This will appear on top of [member cell_flag_bg].
@export var cell_flag_bg: Texture2D ## The background texture used for cells in this stage that are flagged. This will appear below [cell_flag]
@export var cell_coin_palette: Texture2D ## The palette used for coins in this stage. If set to [code]null[/code], will use the default palette.
@export var cell_heart_palette: Texture2D ## The palette used for hearts in this stage. If set to [code]null[/code], will use the default palette.
# ==============================================================================

func _create_theme() -> Theme:
	var theme := Theme.new()
	
	theme.set_icon("bg", "Cell", cell_bg)
	theme.set_icon("checking", "Cell", cell_checking)
	if cell_coin_palette:
		theme.set_icon("coin_palette", "Cell", cell_coin_palette)
	if cell_heart_palette:
		theme.set_icon("heart_palette", "Cell", cell_heart_palette)
	theme.set_icon("flag", "Cell", cell_flag)
	theme.set_icon("flag_bg", "Cell", cell_flag_bg)
	theme.set_icon("hidden", "Cell", cell_hidden)
	
	theme.set_icon("bg", "StageScene", bg)
	
	return theme


func _get_name() -> String:
	return name


func _get_bg() -> Texture2D:
	return bg


func generate_monster_name() -> String:
	return monster_name_pool.pick_random()


func _get_music() -> AudioStream:
	return music


func _get_ambience_a() -> AudioStream:
	return ambience_a


func _get_ambience_b() -> AudioStream:
	return ambience_b


func _get_artifacts() -> Array[StageFile]:
	if not artifact_texture:
		return []
	return [self]


func _autofill(use_wiki: bool = true) -> void:
	if resource_path.is_empty():
		return
	
	name = "stage." + resource_path.get_file().get_basename().to_snake_case().replace("_", "-")
	
	var dir := resource_path.get_base_dir()
	
	if ResourceLoader.exists(dir.path_join("bg.png")):
		bg = load(dir.path_join("bg.png"))
	if ResourceLoader.exists(dir.path_join("empty.png")):
	
		cell_bg = load(dir.path_join("empty.png"))
	if ResourceLoader.exists(dir.path_join("full.png")):
		cell_hidden = load(dir.path_join("full.png"))
	if ResourceLoader.exists(dir.path_join("checking.png")):
		cell_checking = load(dir.path_join("checking.png"))
	if ResourceLoader.exists(dir.path_join("flag.png")):
		cell_flag = load(dir.path_join("flag.png"))
	if ResourceLoader.exists(dir.path_join("flag_bg.png")):
		cell_flag_bg = load(dir.path_join("flag_bg.png"))
	
	if ResourceLoader.exists(dir.path_join("coin.png")):
		cell_coin_palette = load(dir.path_join("coin.png"))
	if ResourceLoader.exists(dir.path_join("heart.png")):
		cell_heart_palette = load(dir.path_join("heart.png"))
	
	if ResourceLoader.exists(dir.path_join("monster.png")):
		monster_texture = load(dir.path_join("monster.png"))
	
	if ResourceLoader.exists(dir.path_join("ambience_a.ogg")):
		ambience_a = load(dir.path_join("ambience_a.ogg"))
	if ResourceLoader.exists(dir.path_join("ambience_b.ogg")):
		ambience_b = load(dir.path_join("ambience_b.ogg"))
	if ResourceLoader.exists(dir.path_join("music.ogg")):
		music = load(dir.path_join("music.ogg"))
	
	await _autofill_monster_names(use_wiki)


func _autofill_monster_names(use_wiki: bool = true) -> void:
	if _monster_pools_reloading:
		await _monster_pools_reloaded
	
	var dir := resource_path.get_base_dir()
	
	if FileAccess.file_exists(dir.path_join("properties.ini")):
		var cfg := ConfigFile.new()
		cfg.load(dir.path_join("properties.ini"))
		if cfg.has_section_key("monsters", "names"):
			var monster_names := PackedStringArray()
			for monster_name in cfg.get_value("monsters", "names"):
				monster_names.append(monster_name)
			
			if not monster_name_pool:
				monster_name_pool = StringTable.new()
			monster_name_pool.data.en = monster_names
			_monster_pools_cache[name] = monster_names
			return
	
	if name in _monster_pools_cache:
		if not monster_name_pool:
			monster_name_pool = StringTable.new()
		monster_name_pool.data.en = _monster_pools_cache[name]
		return
	
	if not use_wiki:
		return
	
	_monster_pools_reloading = true
	
	_monster_pools_cache.clear()
	
	var client := await QuickRun.connect_to_host()
	
	var json_text := await QuickRun.get_url_text(client, "/wiki/api.php?titles=Monsters&action=query&format=json&prop=revisions&rvprop=content&rvslots=main")
	if json_text.is_empty():
		_monster_pools_reloading = false
		_monster_pools_reloaded.emit()
		return
	
	var json = JSON.parse_string(json_text)
	if json == null:
		_monster_pools_reloading = false
		_monster_pools_reloaded.emit()
		return
	
	var pages_dict: Dictionary = json.query.pages
	var text: String = pages_dict[pages_dict.keys()[0]].revisions[0].slots.main["*"]
	
	FileAccess.open("user://temp.txt", FileAccess.WRITE).store_string(text)
	
	var i := 0
	var last_stage_name := ""
	while true:
		i = text.find("===", i) + 3
		if i < 3:
			break
		
		var names := PackedStringArray()
		names.append(text.substr(i, text.find("===", i) - i))
		
		i = text.find("Appears in", i)
		i = text.find("{{", i)
		assert(i >= 0)
		
		var stages := PackedStringArray()
		for stage_id in Stringifier.split_ignoring_nested(text.substr(i, text.find(".", i) - i), ", "):
			var stage_name := "stage." + stage_id.trim_prefix("{{Stage|").trim_suffix("}}").to_snake_case().replace("_", "-")
			assert(stage_name != last_stage_name, "Cursor got stuck at i = " + str(i) + ".")
			last_stage_name = stage_name
			stages.append(stage_name)
		
		i = text.find("Alternative names: ", i) + 19
		assert(i >= 19)
		names.append_array(Stringifier.split_ignoring_nested(text.substr(i, text.find(".", i) - i), ", "))
		
		for stage_name in stages:
			_monster_pools_cache[stage_name] = names
			
			print(stage_name, ": ", ", ".join(names))
		
		print("i = ", i)
	
	if name in _monster_pools_cache:
		if not monster_name_pool:
			monster_name_pool = StringTable.new()
		monster_name_pool.data.en = _monster_pools_cache[name]
	
	print(_monster_pools_cache.keys())
	
	_monster_pools_reloading = false
	_monster_pools_reloaded.emit()
