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

func _init() -> void:
	changed.connect(func() -> void:
		_texture = null
	)


## Creates a new [StatusEffect]. Uses the given [code]uid[/code] if specified.
func create_status(uid: String = "") -> StatusEffect.Initializer:
	return StatusEffect.create(uid).set_source(self)

#region internals

func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	#RenderingServer.canvas_item_add_rect(to_canvas_item, Rect2(Vector2.ZERO, get_size()), _get_texture_bg_color())
	_texture.draw(to_canvas_item, pos, modulate, transpose)


func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	#RenderingServer.canvas_item_add_rect(to_canvas_item, rect, _get_texture_bg_color())
	_texture.draw_rect(to_canvas_item, rect, tile, modulate, transpose)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	#RenderingServer.canvas_item_add_rect(to_canvas_item, rect, _get_texture_bg_color())
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


## Virtual method to add an effect for when the [Collectible] is used. Note that,
## by default, nothing prevents the player from using the collectible again afterwards.
func _use() -> void:
	pass


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
