@tool
extends StageBase
class_name Stage

## A single stage in a [Quest].

# ==============================================================================
const BG_TEXTURE_PATH := "res://assets/skins/%s/bg.png"
const MUSIC_PATH := "res://assets/skins/%s/music.ogg"
const AMBIENCE_A_PATH := "res://assets/skins/%s/ambience_a.ogg"
const AMBIENCE_B_PATH := "res://assets/skins/%s/ambience_b.ogg"
# ==============================================================================
static var _theme_cache: Dictionary[String, Theme] = {}
# ==============================================================================
@export var file: StageFile :
	set(value):
		if file == value:
			return
		
		file = value
		
		queue_changed()

@export var size := Vector2i.ZERO : ## The size of the stage.
	set(value):
		if size == value:
			return
		
		size = value
		
		queue_changed()
@export var monsters := 0 : ## The number of monsters in the stage.
	set(value):
		if monsters == value:
			return
		
		monsters = maxi(1, value)
		
		queue_changed()
@export var min_power := 0 : ## The stage's minimum power.
	set(value):
		if min_power == value:
			return
		
		min_power = value
		
		queue_changed()
@export var max_power := 0 : ## The stage's maximum power.
	set(value):
		if max_power == value:
			return
		
		max_power = value
		
		queue_changed()

@export var mods: Array[StageMod] = [] : ## The stage's mods.
	set(value):
		if mods == value:
			return
		
		mods = value
		
		queue_changed()
# ==============================================================================

@warning_ignore("shadowed_variable")
func _init(file: StageFile = null, size: Vector2i = Vector2i.ZERO, monsters: int = 0) -> void:
	self.file = file
	self.size = size
	self.monsters = monsters


func _get_name_id() -> String:
	return file.name


## Returns the total area of this [Stage], i.e. the number of [Cell]s.
func area() -> int:
	return size.x * size.y


func _get_info() -> Array:
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


## Virtual method to override the return value of [method get_description_id].
func _get_description_id() -> String:
	return get_name_id().to_snake_case().replace("_", "-") + ".description"


## Returns a [Theme] instance for this [Stage], with all relevant properties set
## to this [Stage]'s theme.
func get_theme() -> Theme:
	return file.create_theme()


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


func _get_bg() -> Texture2D:
	return file.bg


## Reimplements [method StageBase.get_instance] for easy typing.
func get_instance() -> StageInstance:
	return super()


## Reimplements [method StageBase.create_instance] for easy typing.
func create_instance() -> StageInstance:
	return super()


func _create_instance() -> StageInstance:
	return StageInstance.new()


## Returns whether the specified [param coord] is inside this [Stage].
func has_coord(coord: Vector2i) -> bool:
	if coord.x < 0 or coord.y < 0:
		return false
	if coord.x >= size.x or coord.y >= size.y:
		return false
	
	return true


## Reimplements [method StageBase.get_scene] for easy typing.
func get_scene() -> StageScene:
	return super()


## Returns this [Stage]'s density, i.e. [code]monsters / area[/code].
func get_density() -> float:
	return float(monsters) / area()


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
	
	var stage_name := get_name_id().substr(get_name_id().rfind(".") + 1)
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
#static func generate(base: QuestFile.StageTemplate, rng: RandomNumberGenerator) -> Stage: # (stage_name: String, index: int, toughness: float, rng: RandomNumberGenerator) -> Stage:
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
