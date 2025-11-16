@tool
@abstract
extends ResourceNode
class_name StageBase

# ==============================================================================
static var music_volume: float = Eternal.create(1.0, "settings")
# ==============================================================================
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
# ==============================================================================
var _icon_small: Texture2D = null : get = get_small_icon
var _icon_large: Texture2D = null : get = get_large_icon
# ==============================================================================

## Returns whether this is a special stage. Special stages are skipped when unlocking
## new stages, and they don't have to be completed to finish the quest.
## [br][br][b]Note:[/b] This is not the same as checking for [code]stage is SpecialStage[/code].
## All [SpecialStage]s are special, but some non-[SpecialStage]s are also special.
func is_special() -> bool:
	return _is_special()


## Virtual method. Should return [code]true[/code] if this stage is special.
## When extending [SpecialStage], this is done automatically. Overriding this method
## can be used to make non-[SpecialStage]s also be treated as special stages.
func _is_special() -> bool:
	return false


## Returns this stage's name as a translatable [String].
func get_name_id() -> String:
	return _get_name_id()


## Virtual method. Should return the stage's name as a translatable [String].
@abstract func _get_name_id() -> String


## Returns this stage's info, as an [Array]. Each element can be of the following
## types:
## [br]- [Texture2D]: The given texture should be rendered.
## [br]- [Color]: The next [String] should be rendered using this [Color].
## [br]- [String]: The given [String] should be rendered using the previously
## assigned [Color], or white is no one was specifiied (yet)
## [br]- [int]: The rendered [Control]s should be separated by the given number
## of pixels.
func get_info() -> Array:
	return _get_info()


## Virtual method. Should return this stage's info, to be rendered in its details.
## See [method get_info] for more info.
@abstract func _get_info() -> Array


## Returns this stage's description as a translatable [String].
func get_description_id() -> String:
	return _get_description_id()


## Virtual method. Should return this stage's description as a translatable [String].
@abstract func _get_description_id() -> String


## Creates and returns a new [StageIcon] for this [Stage].
func create_icon() -> StageIcon:
	var icon := load("res://engine/scenes/stage_select/stage_icon.tscn").instantiate() as StageIcon
	icon.stage = self
	return icon


## Returns this stage's background texture.
func get_bg() -> Texture2D:
	return _get_bg()


## Virtual method. Should return this stage's background texture.
@abstract func _get_bg() -> Texture2D


## Returns this [Stage]'s small icon (the one shown in the [StageSelect] screen,
## in the [StagesOverview]).
func get_small_icon() -> Texture2D:
	if not _icon_small:
		_icon_small = _get_small_icon()
	
	return _icon_small


## Virtual method. Should return this stage's small icon (the one shown in the
## [StageSelect] screen, in the [StagesOverview]).
## [br][br]If not overridden, returns a shrunk down version of the background
## texture (see [method get_bg]).
func _get_small_icon() -> Texture2D:
	var bg := get_bg()
	
	if not bg:
		return get_window().get_theme_icon("question_mark", "Stage")
	
	var image := _shrink(bg.get_image(), 16)
	
	return ImageTexture.create_from_image(image)


## Returns this stage's large icon (the one shown in the [StageSelect]
## screen, in the [StageDetails]).
func get_large_icon() -> Texture2D:
	if not _icon_large:
		_icon_large = _get_large_icon()
	
	return _icon_large


## Virtual method. Should return this stage's large icon (the one shown in the
## [StageSelect] screen, in the [StageDetails]).
## [br][br]If not overridden, returns a shrunk down version of the background
## texture (see [method get_bg]).
func _get_large_icon() -> Texture2D:
	var bg := get_bg()
	
	if not bg:
		return ImageTexture.create_from_image(Image.create_empty(58, 58, false, Image.FORMAT_RGB8))
	
	var image := _shrink(bg.get_image(), 58)
	
	return ImageTexture.create_from_image(image)


## Returns a stage instance for this stage, if there is one.
func get_instance() -> StageInstanceBase:
	for child in get_children():
		if child is StageInstanceBase:
			return child
	return null


## Returns [code]true[/code] if this stage has a stage instance.
func has_instance() -> bool:
	return get_instance() != null


## Creates and returns a new instance of this stage. Does not check if one already
## exists.
func create_instance() -> StageInstanceBase:
	var instance := _create_instance()
	add_child(instance)
	return instance


## Virtual method. Should create a new instance of this stage. Does not need to
## check if one already exists. Also does not need to add it to the scene tree.
@abstract func _create_instance() -> StageInstanceBase


## Clears this stage's instance.
func clear_instance() -> void:
	if has_instance():
		get_instance().queue_free()


## Returns the currently active [StageScene].
func get_scene() -> Node:
	if has_instance():
		return get_instance().get_scene()
	return null


func get_mods() -> Array[StageMod]:
	return _get_mods()


func _get_mods() -> Array[StageMod]:
	return []


func _shrink(image: Image, new_size: int) -> Image:
	var large_axis := maxi(image.get_width(), image.get_height())
	var small_axis := mini(image.get_width(), image.get_height())
	var max_axis_idx := image.get_size().max_axis_index()
	var pos := Vector2i.ZERO
	pos[max_axis_idx] = large_axis / 2 - small_axis / 2
	image = image.get_region(Rect2i(pos, Vector2i(small_axis, small_axis)))
	
	image.resize(new_size, new_size)
	
	return image
