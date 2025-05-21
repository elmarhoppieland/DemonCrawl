@tool
extends AnnotatedTexture
class_name Collectible

## An abstract object that can be collected by the player.

# ==============================================================================
var _texture: ImageTexture :
	get:
		if _texture:
			return _texture
		
		var texture := _get_atlas()
		if not texture:
			return null
		var region := _get_atlas_region()
		if not region:
			_texture = ImageTexture.create_from_image(texture.get_image())
			return _texture
		
		var image := texture.get_image().get_region(_get_atlas_region())
		_texture = ImageTexture.create_from_image(_parse_image(image))
		return _texture

# ==============================================================================
@export var _origin_path := "" : get = get_origin_path
# ==============================================================================

func _init() -> void:
	changed.connect(func() -> void:
		_texture = null
	)


## Creates a new [StatusEffect]. Uses the given [code]uid[/code] if specified.
func create_status(uid: String = "") -> StatusEffect.Initializer:
	return StatusEffect.create(uid).set_source(self)

#region internals

func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	_texture.draw(to_canvas_item, pos, modulate, transpose)


func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	_texture.draw_rect(to_canvas_item, rect, tile, modulate, transpose)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	_texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)


func _get_width() -> int:
	return _texture.get_width()


func _get_height() -> int:
	return _texture.get_height()


func _has_alpha() -> bool:
	return _texture.has_alpha()

#endregion

## Returns the main [SceneTree].
func get_tree() -> SceneTree:
	return Engine.get_main_loop()


## Virtual method to override this texture's atlas to be read from.
func _get_atlas() -> Texture2D:
	return null


## Virtual method to override this texture's atlas region to read the atlas from.
## [br][br][b]Note:[/b] [method _get_atlas] must be overridden and return a valid
## [Texture2D] for this method to be called.
func _get_atlas_region() -> Rect2:
	return Rect2()


## Returns this collectible's background [Color].
func get_texture_bg_color() -> Color:
	return _get_texture_bg_color()


## Virtual method to override this texture's background color. Will default to a
## transparent background if not overridden.
func _get_texture_bg_color() -> Color:
	return Color.TRANSPARENT


## Virtual method to make final modifications to this collectible's [Image],
## after cropping it and applying a background. Should return the final [Image].
func _parse_image(image: Image) -> Image:
	return image


## Uses this [Collectible], if possible. First calls [method _use], and then [method _post].
func use() -> void:
	if can_use():
		_use()
		post()


## Virtual method to add an effect for when the [Collectible] is used. Note that, by default,
## nothing prevents the player from using the collectible again afterwards. To prevent this,
## add a cost in [method _post].
## [br][br][b]Note:[/b] If using the [Collectible] requires player input, [method _invoke]
## should also be overridden to allow non-player game effects to invoke the [Collectible].
## If using the [Collectible] does not require player input, this is not needed and
## [method _use] is called when the [Collectible] is invoked.
func _use() -> void:
	pass


## Posts this [Collectible]. This usally means performing its cost, like losing it.
func post() -> void:
	_post()


## Virtual method. Called after this [Collectible] is used. Should perform the [Collectible]'s
## cost, e.g. losing it. Not called if the [Collectible] is invoked.
func _post() -> void:
	pass


## Invokes the [Collectible], if possible. This means that the [Collectible] will be used
## without player input, often by randomly selecting a player's choice, e.g. picking
## the targeted [Cell] randomly.
func invoke() -> void:
	_invoke()


## Virtual method. Usually called when the [Collectible] is used by a game effect that is not the player.
## Should use the [Collectible] without requiring player input. If the [Collectible] requires a
## target [Cell], should target it on a random [Cell].
func _invoke() -> void:
	_use()


## Returns whether this collectible can be used. If this returns [code]true[/code],
## and the collectible is interacted with, [method _use] will be called.
func can_use() -> bool:
	return is_active() and _can_use()


## Virtual method to override the return value of [method can_use].
func _can_use() -> bool:
	return false


## Returns whether this [Collectible] is active, i.e. it can be interacted with
## in its current state.
func is_active() -> bool:
	return _is_active()


## Virtual method to override the return value of [method is_active].
func _is_active() -> bool:
	return false


## Returns whether this [Collectible] is currently blinking.
func is_blinking() -> bool:
	return _is_blinking()


## Virtual method to override the return value of [method is_blinking].
func _is_blinking() -> bool:
	return false


## Returns whether this [Collectible] has a progress bar.
func has_progress_bar() -> bool:
	return _has_progress_bar()


## Virtual method to override the return value of [method has_progress_bar].
func _has_progress_bar() -> bool:
	return false


## Returns this [Collectible]'s progress bar's progress value. [method has_progress_bar]
## must return true for this to be called, and [method get_max_progress] should return
## a non-zero value.
func get_progress() -> int:
	return _get_progress()


## Virtual method to override the return value of [method get_progress].
func _get_progress() -> int:
	return 0

## Returns this [Collectible]'s progress bar's maximum progress value. [method has_progress_bar]
## must return true for this to be called.
func get_max_progress() -> int:
	return _get_max_progress()


func _get_max_progress() -> int:
	return 0


## Returns the original path that this [Collectible] was stored at on the filesystem.
## If this is a duplicate of a saved [Collectible], this returns the path of the
## original [Collectible].
func get_origin_path() -> String:
	if _origin_path.is_empty() and not resource_path.is_empty():
		_origin_path = resource_path
	return _origin_path
