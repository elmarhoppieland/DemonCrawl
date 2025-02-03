@tool
extends Resource
class_name Stage

## A single stage in a [Quest].

# ==============================================================================
const BG_TEXTURE_PATH := "res://Assets/skins/%s/bg.png"
const MUSIC_PATH := "res://Assets/skins/%s/music.ogg"
const AMBIENCE_A_PATH := "res://Assets/skins/%s/ambience_a.ogg"
const AMBIENCE_B_PATH := "res://Assets/skins/%s/ambience_b.ogg"

# ==============================================================================
static var _current: Stage = Eternal.create(null) : get = get_current
var _audio_streams: Array[AudioStreamOggVorbis] = []
var _audio_players: Array[AudioStreamPlayer] = []
# ==============================================================================
@export var name := "" : ## The name of the stage.
	set(value):
		if name == value:
			return
		
		name = value
		
		emit_changed()
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
		
		monsters = value
		
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
@export var _instance: StageInstance : get = get_instance
# ==============================================================================
var _scene: StageScene : get = get_scene
var _theme: Theme : get = get_theme
# ==============================================================================

func _init(_name: String = "", _size: Vector2i = Vector2i.ZERO, _monsters: int = 0) -> void:
	name = _name
	size = _size
	monsters = _monsters


## Returns the currently active [Stage]. Returns [code]null[/code] if there is no
## active [Stage], for example when the player is on the [StageSelect] scene or
## no [Quest] is active.
## [br][br]See also [method has_current].
static func get_current() -> Stage:
	return _current


## Returns whether there is an active [Stage].
## [br][br]See also [method get_current].
static func has_current() -> bool:
	return get_current() != null


## Resets the current [Stage] to [code]null[/code]. This means no [Stage] is set as
## the current [Stage].
static func clear_current() -> void:
	_current = null


## Sets this [Stage] as the current stage. Future calls to [method get_current] will
## return this [Stage].
func set_as_current() -> void:
	_current = self


func finish() -> void:
	completed = true
	clear_instance()


## Returns the total area of this [Stage], i.e. the number of [Cell]s.
func area() -> int:
	return size.x * size.y


## Returns a [Theme] instance for this [Stage], with all relevant properties set
## to this [Stage]'s theme.
func get_theme() -> Theme:
	if _theme:
		return _theme
	
	_theme = Theme.new()
	
	var dir := "res://Assets/skins/%s/" % name
	_theme.set_icon("bg", "Cell", load(dir + "empty.png"))
	_theme.set_icon("checking", "Cell", load(dir + "checking.png"))
	if ResourceLoader.exists(dir + "coin.png"):
		_theme.set_icon("coin_palette", "Cell", load(dir + "coin.png"))
	_theme.set_icon("flag", "Cell", load(dir + "flag.png"))
	_theme.set_icon("flag_bg", "Cell", load(dir + "flag_bg.png"))
	_theme.set_icon("hidden", "Cell", load(dir + "full.png"))
	if ResourceLoader.exists(dir + "monster.png"):
		_theme.set_icon("monster_atlas", "Cell", load(dir + "monster.png"))
	
	_theme.set_icon("bg", "StageScene", load(dir + "bg.png"))
	
	return _theme


## Creates and returns a new [StageIcon] for this [Stage].
func create_icon() -> StageIcon:
	var icon := load("res://Scenes/StageSelect/StageIcon.tscn").instantiate() as StageIcon
	icon.stage = self
	return icon


## Loads music and ambience into _audio_streams
func load_music() -> void:
	for music_path in [MUSIC_PATH, AMBIENCE_A_PATH, AMBIENCE_B_PATH]:
		var full_music_path = music_path % name
		if FileAccess.file_exists(full_music_path):
			var audio_stream = load(full_music_path)
			if audio_stream is AudioStreamOggVorbis:
				audio_stream.loop = true
				_audio_streams.append(audio_stream)
			else:
				Toasts.add_debug_toast("Failed to load music at %s" % full_music_path)


## Creates _audio_players and adds them to the [Scene]
func create_audio_players() -> void:
	for stream in _audio_streams:
		var audio_player = AudioStreamPlayer.new()
		audio_player.stream = stream
		get_scene().add_child(audio_player)
		_audio_players.append(audio_player)


func start_audio_players() -> void:
	for player in _audio_players:
		player.play()


func play_music() -> void:
	load_music()
	create_audio_players()
	start_audio_players()


func stop_music() -> void:
	for player in _audio_players:
		player.stop()
	_audio_players.clear()
	_audio_streams.clear()


## Returns a [StageInstance] for this [Stage]. Reuses the same one if one was already created.
func get_instance() -> StageInstance:
	if self != Stage.get_current():
		return null
	
	if not _instance:
		_instance = StageInstance.new()
		_instance.set_stage(self)
	return _instance


## Clears this [Stage]'s [StageInstance]. The next call to [method get_instance] will
## create a new instance.
func clear_instance() -> void:
	_instance = null


## Returns whether the specified [code]coord[/code] is inside this [Stage].
func has_coord(coord: Vector2i) -> bool:
	if coord.x < 0 or coord.y < 0:
		return false
	if coord.x >= size.x or coord.y >= size.y:
		return false
	
	return true


func get_bg_texture() -> CompressedTexture2D:
	return load(BG_TEXTURE_PATH % name)


func create_big_icon() -> ImageTexture:
	var image: Image = ResourceLoader.load("res://Assets/skins".path_join(name).path_join("bg.png")).get_image()
	
	image = image.get_region(Rect2i(image.get_width() / 2 - image.get_height() / 2, 0, image.get_height(), image.get_height()))
	image.resize(58, 58)
	
	return ImageTexture.create_from_image(image)


## Returns the currently active [StageScene].
func get_scene() -> StageScene:
	if is_instance_valid(_scene):
		return _scene
	
	var loop := Engine.get_main_loop()
	assert(loop is SceneTree, "Expected a SceneTree as the main loop, but a %s was found." % loop.get_class())
	
	var current_scene := (loop as SceneTree).current_scene
	if current_scene is StageScene:
		_scene = current_scene
	
	return _scene


func get_board() -> Board:
	return get_scene().get_board()


func roll_power() -> int:
	return randi_range(min_power, max_power)


## Returns a property of this [Stage].
func get_property(section: String, key: String, default: Variant = null) -> Variant:
	var cfg := ConfigFile.new()
	
	var stage_name := name
	var value: Variant = null
	while true:
		cfg.load("res://Assets/skins/%s/properties.ini" % stage_name)
		value = cfg.get_value(section, key, default)
		if value != default and value is String and value.begins_with("->"):
			stage_name = value.trim_prefix("->").strip_edges()
		else:
			break
	
	return value


# TODO: This is not accurate, we need to collect data about DemonCrawl's generation
static func generate(base: QuestFile.StageBase, rng: RandomNumberGenerator) -> Stage: # (stage_name: String, index: int, toughness: float, rng: RandomNumberGenerator) -> Stage:
	var stage := Stage.new(base.name)
	
	stage.size.x = rng.randi_range(base.size[0], base.size[-1])
	stage.size.y = rng.randi_range(base.size[0], base.size[-1])
	
	stage.min_power = rng.randi_range(base.min_power[0], base.min_power[-1])
	stage.max_power = rng.randi_range(base.max_power[0], base.max_power[-1])
	
	stage.monsters = rng.randi_range(base.monsters[0], base.monsters[-1])
	
	var total_difficulty := rng.randi_range(0, 4)
	while total_difficulty > 0:
		break # TODO
		var mod := StageModDB.create_filter().get_random_mod()
		stage.mods.append(mod)
		total_difficulty -= mod.data.difficulty
	
	return stage
	
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
