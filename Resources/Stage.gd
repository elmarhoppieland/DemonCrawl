extends RefCounted
class_name Stage

## A single stage in a quest.

# ==============================================================================
const BG_TEXTURE_PATH := "res://Assets/skins/%s/bg.png"
# ==============================================================================
var name := "" : ## The name of the stage.
	set(value):
		if name == value:
			return
		
		name = value
		
		properties_changed.emit()
var size := Vector2i.ZERO : ## The size of the stage.
	set(value):
		if size == value:
			return
		
		size = value
		
		properties_changed.emit()
var monsters := 0 : ## The number of monsters in the stage.
	set(value):
		if monsters == value:
			return
		
		monsters = value
		
		properties_changed.emit()
var min_power := 0 : ## The stage's minimum power.
	set(value):
		if min_power == value:
			return
		
		min_power = value
		
		properties_changed.emit()
var max_power := 0 : ## The stage's maximum power.
	set(value):
		if max_power == value:
			return
		
		max_power = value
		
		properties_changed.emit()

var locked := false : ## Whether the stage is locked.
	set(value):
		if locked == value:
			return
		
		locked = value
		
		properties_changed.emit()
var completed := false : ## Whether the stage is completed.
	set(value):
		if completed == value:
			return
		
		completed = value
		
		properties_changed.emit()
# ==============================================================================
signal properties_changed()
# ==============================================================================

func _init(_name: String = "", _size: Vector2i = Vector2i.ZERO, _monsters: int = 0) -> void:
	name = _name
	size = _size
	monsters = _monsters


func area() -> int:
	return size.x * size.y


func get_bg_texture() -> CompressedTexture2D:
	return ResourceLoader.load(BG_TEXTURE_PATH % name)


func create_big_icon() -> ImageTexture:
	var image: Image = ResourceLoader.load("res://Assets/skins".path_join(name).path_join("bg.png")).get_image()
	
	image = image.get_region(Rect2i(image.get_width() / 2 - image.get_height() / 2, 0, image.get_height(), image.get_height()))
	image.resize(58, 58)
	
	return ImageTexture.create_from_image(image)


## Returns a property of the current stage.
static func get_property(section: String, key: String, default: Variant = null, stage_name: String = StagesOverview.selected_stage.name) -> Variant:
	var cfg := ConfigFile.new()
	cfg.load("res://Assets/skins/%s/properties.ini" % stage_name)
	var value = cfg.get_value(section, key, default)
	if value != default and value is String and value.begins_with("->"):
		return get_property(section, key, default, value.trim_prefix("->").strip_edges())
	return value


# TODO: This is not accurate, we need to collect data about DemonCrawl's generation
static func generate(base: QuestFile.StageBase, rng: RandomNumberGenerator) -> Stage: # (stage_name: String, index: int, toughness: float, rng: RandomNumberGenerator) -> Stage:
	var stage := Stage.new(base.name)
	
	stage.size.x = rng.randi_range(base.size[0], base.size[-1])
	stage.size.y = rng.randi_range(base.size[0], base.size[-1])
	
	stage.min_power = rng.randi_range(base.min_power[0], base.min_power[-1])
	stage.max_power = rng.randi_range(base.max_power[0], base.max_power[-1])
	
	stage.monsters = rng.randi_range(base.monsters[0], base.monsters[-1])
	
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
