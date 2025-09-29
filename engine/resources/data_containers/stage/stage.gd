@tool
extends Node
class_name Stage

## A single stage in a [Quest].

# ==============================================================================
const BG_TEXTURE_PATH := "res://assets/skins/%s/bg.png"
const MUSIC_PATH := "res://assets/skins/%s/music.ogg"
const AMBIENCE_A_PATH := "res://assets/skins/%s/ambience_a.ogg"
const AMBIENCE_B_PATH := "res://assets/skins/%s/ambience_b.ogg"
# ==============================================================================
static var music_volume: float = Eternal.create(1.0, "settings")

static var _theme_cache := {}
# ==============================================================================
@export var size := Vector2i.ZERO : ## The size of the stage.
	set(value):
		if size == value:
			return
		
		size = value
		
		emit_changed()
@export var monsters := 0 : ## The number of monsters in the stage.
	set(value):
		if monsters == value:
			return
		
		monsters = maxi(1, value)
		
		emit_changed()
@export var min_power := 0 : ## The stage's minimum power.
	set(value):
		if min_power == value:
			return
		
		min_power = value
		
		emit_changed()
@export var max_power := 0 : ## The stage's maximum power.
	set(value):
		if max_power == value:
			return
		
		max_power = value
		
		emit_changed()

@export var locked := false : ## Whether the stage is locked.
	set(value):
		if locked == value:
			return
		
		locked = value
		
		emit_changed()
@export var completed := false : ## Whether the stage is completed.
	set(value):
		if completed == value:
			return
		
		completed = value
		
		emit_changed()

@export var mods: Array[StageMod] = [] : ## The stage's mods.
	set(value):
		if mods == value:
			return
		
		mods = value
		
		emit_changed()
# ==============================================================================
var _theme: Theme : get = get_theme

var _icon_large: Texture2D = null : get = get_large_icon
var _icon_small: Texture2D = null : get = get_small_icon

var _audio_streams: Array[AudioStreamOggVorbis] = []
var _audio_players: Array[AudioStreamPlayer] = []
# ==============================================================================
signal changed()
# ==============================================================================

func _init(_name: String = "", _size: Vector2i = Vector2i.ZERO, _monsters: int = 0) -> void:
	if not _name.is_empty():
		name = _name
	size = _size
	monsters = _monsters


func emit_changed() -> void:
	changed.emit()


## Returns the total area of this [Stage], i.e. the number of [Cell]s.
func area() -> int:
	return size.x * size.y


## Returns this [Stage]'s name as a translatable [String].
func get_name_id() -> String:
	var override := _get_name_id()
	if not override.is_empty():
		return override
	return "stage." + name.to_snake_case().replace("_", "-")


## Virtual method to override the return value of [method get_name_id].
func _get_name_id() -> String:
	return ""


func get_info() -> Array:
	var override := _get_info()
	if not override.is_empty():
		return override
	
	if completed:
		return [
			5,
			Color("10df80"),
			"stage-select.details.property.complete"
		]
	
	return [
		4,
		get_window().get_theme_icon("power5", "Stage"),
		2,
		"%d-%d" % [min_power, max_power],
		6,
		get_window().get_theme_icon("monster5", "Stage"),
		3,
		str(monsters),
		7,
		get_window().get_theme_icon("size5", "Stage"),
		3,
		str(area())
	]


func _get_info() -> Array:
	return []


## Returns this [Stage]'s description as a translatable [String].
func get_description_id() -> String:
	var override := _get_description_id()
	if not override.is_empty():
		return override
	return "stage." + name.to_snake_case().replace("_", "-") + ".description"


## Virtual method to override the return value of [method get_description_id].
func _get_description_id() -> String:
	return ""


## Returns a [Theme] instance for this [Stage], with all relevant properties set
## to this [Stage]'s theme.
func get_theme() -> Theme:
	if not _theme:
		_theme = _get_theme()
	
	return _theme


func _get_theme() -> Theme:
	return Stage.create_theme(name)


static func create_theme(stage_name: String) -> Theme:
	if stage_name in _theme_cache:
		return _theme_cache[stage_name]
	
	var theme := Theme.new()
	
	var dir := "res://assets/skins/%s/" % stage_name
	theme.set_icon("bg", "Cell", load(dir + "empty.png"))
	theme.set_icon("checking", "Cell", load(dir + "checking.png"))
	if ResourceLoader.exists(dir + "coin.png"):
		theme.set_icon("coin_palette", "Cell", load(dir + "coin.png"))
	if ResourceLoader.exists(dir + "heart.png"):
		theme.set_icon("heart_palette", "Cell", load(dir + "heart.png"))
	theme.set_icon("flag", "Cell", load(dir + "flag.png"))
	theme.set_icon("flag_bg", "Cell", load(dir + "flag_bg.png"))
	theme.set_icon("hidden", "Cell", load(dir + "full.png"))
	if ResourceLoader.exists(dir + "monster.png"):
		var texture := AnimatedTextureSequence.new()
		texture.atlas = load(dir + "monster.png")
		if Engine.is_editor_hint():
			theme.set_icon("monster", "Cell", CustomTextureBase.new(texture))
		else:
			theme.set_icon("monster", "Cell", texture)
	
	theme.set_icon("bg", "StageScene", load(dir + "bg.png"))
	
	_theme_cache[stage_name] = theme
	
	return theme


## Creates and returns a new [StageIcon] for this [Stage].
func create_icon() -> StageIcon:
	var icon := load("res://engine/scenes/stage_select/stage_icon.tscn").instantiate() as StageIcon
	icon.stage = self
	return icon


## Creates and returns this [Stage]'s small icon (the one shown in the [StageSelect] screen, in the [StagesOverview]).
func get_small_icon() -> Texture2D:
	if _icon_small:
		return _icon_small
	
	var override := _get_small_icon()
	if override:
		_icon_small = override
		return override
	
	const IMAGE_PATH := "res://assets/skins/%s/bg.png"
	
	if not ResourceLoader.exists(IMAGE_PATH % name):
		return get_window().get_theme_icon("question_mark", "Stage")
	
	var image: Image = load(IMAGE_PATH % name).get_image()
	image.convert(Image.FORMAT_RGBA8)
	
	var large_axis := maxi(image.get_width(), image.get_height())
	var small_axis := mini(image.get_width(), image.get_height())
	var max_axis_idx := image.get_size().max_axis_index()
	var pos := Vector2i.ZERO
	pos[max_axis_idx] = large_axis / 2 - small_axis / 2
	image = image.get_region(Rect2i(pos, Vector2i(small_axis, small_axis)))
	
	image.resize(16, 16)
	
	for px: Vector2i in [Vector2i(0, 0), Vector2i(15, 0), Vector2i(0, 15), Vector2i(15, 15)]:
		image.set_pixelv(px, Color.TRANSPARENT)
	
	_icon_small = ImageTexture.create_from_image(image)
	return _icon_small


## Virtual method. Should create and return this [Stage]'s small icon (the one shown in the [StageSelect]
## screen, in the [StagesOverview]).
## Return [code]null[/code] use the default behaviour by shrinking this [Stage]'s background.
func _get_small_icon() -> Texture2D:
	return null


## Creates and return this [Stage]'s large icon (the one shown in the [StageSelect] screen, in the [StageDetails]).
func get_large_icon() -> Texture2D:
	if _icon_large:
		return _icon_large
	
	var override := _get_large_icon()
	if override:
		_icon_large = override
		return override
	
	if not ResourceLoader.exists("res://assets/skins/%s/bg.png" % name):
		return ImageTexture.create_from_image(Image.create(58, 58, false, Image.FORMAT_RGB8))
	
	var image: Image = load("res://assets/skins/%s/bg.png" % name).get_image()
	
	image = image.get_region(Rect2i(image.get_width() / 2 - image.get_height() / 2, 0, image.get_height(), image.get_height()))
	image.resize(58, 58)
	
	_icon_large = ImageTexture.create_from_image(image)
	return _icon_large


## Virtual method. Should create and return this [Stage]'s large icon (the one shown in the [StageSelect]
## screen, in the [StageDetails]).
## Return [code]null[/code] to use the default behaviour by shrinking this [Stage]'s background.
func _get_large_icon() -> Texture2D:
	return null


# Loads music and ambience into _audio_streams
func _load_music() -> void:
	for music_path: String in [MUSIC_PATH, AMBIENCE_A_PATH, AMBIENCE_B_PATH]:
		var full_music_path := music_path % name
		if ResourceLoader.exists(full_music_path):
			var audio_stream := load(full_music_path)
			if audio_stream is AudioStreamOggVorbis:
				audio_stream.loop = true
				_audio_streams.append(audio_stream)
			else:
				Debug.log_error("Failed to load music at %s" % full_music_path)


# Creates _audio_players and adds them to the StageScene
func _create_audio_players() -> void:
	for stream in _audio_streams:
		var audio_player := AudioStreamPlayer.new()
		audio_player.stream = stream
		audio_player.volume_linear *= music_volume
		get_scene().add_child(audio_player)
		_audio_players.append(audio_player)


func _start_audio_players() -> void:
	for player in _audio_players:
		player.play()


func play_music() -> void:
	_load_music()
	_create_audio_players()
	_start_audio_players()


func stop_music() -> void:
	for player in _audio_players:
		player.stop()
		player.queue_free()
	_audio_players.clear()
	_audio_streams.clear()


## Returns a [StageInstance] for this [Stage].
func get_instance() -> StageInstance:
	for child in get_children():
		if child is StageInstance:
			return child
	return null


## Returns a [StageInstance] for this [Stage]. Reuses an existing one if one was already created.
func create_instance() -> StageInstance:
	if has_instance():
		return get_instance()
	var instance := StageInstance.new()
	add_child(instance)
	return instance


## Returns [code]true[/code] if this [Stage] has a [StageInstance] object.
func has_instance() -> bool:
	return get_instance() != null


## Clears this [Stage]'s [StageInstance].
func clear_instance() -> void:
	get_instance().queue_free()


## Returns whether the specified [param coord] is inside this [Stage].
func has_coord(coord: Vector2i) -> bool:
	if coord.x < 0 or coord.y < 0:
		return false
	if coord.x >= size.x or coord.y >= size.y:
		return false
	
	return true


func get_bg_texture() -> CompressedTexture2D:
	return load(BG_TEXTURE_PATH % name)


## Returns the currently active [StageScene].
func get_scene() -> StageScene:
	if has_instance():
		return get_instance().get_scene()
	return null


## Returns this [Stage]'s density, i.e. [code]monsters / area[/code].
func get_density() -> float:
	return float(monsters) / area()


func has_scene() -> bool:
	return get_scene() != null


func get_board() -> Board:
	return get_scene().get_board()


func roll_power() -> int:
	return randi_range(min_power, max_power)


## Returns the total [StageMod] diffuclty of this [Stage].
func get_mods_difficulty() -> int:
	var difficulty := 0
	for mod in mods:
		difficulty += mod.difficulty
	return difficulty


## Returns a property of this [Stage].
func get_property(section: String, key: String, default: Variant = null) -> Variant:
	var cfg := ConfigFile.new()
	
	var stage_name := name
	var value: Variant = null
	while true:
		cfg.load("res://assets/skins/%s/properties.ini" % stage_name)
		value = cfg.get_value(section, key, default)
		if value != default and value is String and value.begins_with("->"):
			stage_name = value.trim_prefix("->").strip_edges()
		else:
			break
	
	return value


# TODO: This is not accurate, we need to collect data about DemonCrawl's generation
#static func generate(base: QuestFile.StageBase, rng: RandomNumberGenerator) -> Stage: # (stage_name: String, index: int, toughness: float, rng: RandomNumberGenerator) -> Stage:
	#var stage := Stage.new(base.name)
	#
	#stage.size.x = rng.randi_range(base.size[0], base.size[-1])
	#stage.size.y = rng.randi_range(base.size[0], base.size[-1])
	#
	#stage.min_power = rng.randi_range(base.min_power[0], base.min_power[-1])
	#stage.max_power = rng.randi_range(base.max_power[0], base.max_power[-1])
	#
	#stage.monsters = rng.randi_range(base.monsters[0], base.monsters[-1])
	#
	#var total_difficulty := rng.randi_range(0, 4)
	#while total_difficulty > 0:
		#break # TODO
		#var mod := StageModDB.create_filter().get_random_mod()
		#stage.mods.append(mod)
		#total_difficulty -= mod.data.difficulty
	#
	#return stage
	#
	#const SIZE_MEAN := Vector2(8, 8)
	#const SIZE_MEAN_INCREASE := Vector2(1.5, 1.5)
	#const SIZE_DEVIATION := 1.0
	#
	#const MONSTERS_MEAN := 10
	#const MONSTERS_MEAN_INCREASE := 8
	#const MONSTERS_DEVIATION := 2.5
	#
	#const MIN_POWER_MEAN := 1
	#const MIN_POWER_MEAN_INCREASE := 0.4
	#const MIN_POWER_DEVIATION := 0.1
	#
	#const MAX_POWER_MEAN := 1
	#const MAX_POWER_MEAN_INCREASE := 0.9
	#const MAX_POWER_DEVIATION := 0.1
	#
	#var stage := Stage.new(stage_name)
	#
	#for axis in [Vector2i.AXIS_X, Vector2i.AXIS_Y]:
		#stage.size[axis] = int(_rand_value(SIZE_MEAN[axis], SIZE_DEVIATION, SIZE_MEAN_INCREASE[axis], index, toughness, rng))
	#
	#stage.monsters = int(_rand_value(MONSTERS_MEAN, MONSTERS_DEVIATION, MONSTERS_MEAN_INCREASE, index, toughness, rng))
	#
	#stage.min_power = ceili(_rand_value(MIN_POWER_MEAN, MIN_POWER_DEVIATION, MIN_POWER_MEAN_INCREASE, index, toughness, rng))
	#stage.max_power = ceili(_rand_value(MAX_POWER_MEAN, MAX_POWER_DEVIATION, MAX_POWER_MEAN_INCREASE, index, toughness, rng))
	#
	#stage.max_power = maxi(0, stage.max_power)
	#stage.min_power = mini(stage.min_power, stage.max_power)
	#stage.min_power = maxi(0, stage.min_power)
	#
	#return stage


#static func _rand_value(mean: float, deviation: float, mean_increase: float, index: int, toughness: float, rng: RandomNumberGenerator) -> float:
	#return rng.randfn((mean + index * mean_increase) * toughness, deviation * (1 + index * mean_increase / mean))
