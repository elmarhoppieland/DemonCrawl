@tool
extends AnnotatedTexture
class_name CellObject

## A [Cell]'s object.

# ==============================================================================
@export var _cell_position := Vector2i.ZERO ## The board position of the [Cell] this is the object of.
@export var _stage: Stage : get = get_stage
# ==============================================================================
var _texture: Texture2D : get = get_texture
var _material: Material : get = get_material
# ==============================================================================

#region internals

func _init(cell_position: Vector2i = Vector2i.ZERO, stage: Stage = null) -> void:
	_cell_position = cell_position
	_stage = stage
	assert(stage != null)
	
	var delta_sum := [0.0]
	get_tree().process_frame.connect(func() -> void:
		var delta := get_tree().root.get_process_delta_time()
		delta_sum[0] += delta
		animate(delta_sum[0])
	)


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


func _is_pixel_opaque(x: int, y: int) -> bool:
	if x < 0 or y < 0:
		return true
	if x > get_width() or y > get_width():
		return true
	return _texture.get_image().get_pixel(x, y).a8 != 0

#endregion

func get_cell() -> Cell:
	if Engine.is_editor_hint():
		var root := EditorInterface.get_edited_scene_root()
		return root if root is Cell else null
	if get_stage() and get_stage().has_scene():
		return get_stage().get_board().get_cell(_cell_position)
	return null


func get_tree() -> SceneTree:
	return Engine.get_main_loop()


func get_stage() -> Stage:
	return _stage


## Clears this [CellObject], setting the cell's object to [code]null[/code].
func clear() -> void:
	get_cell().clear_object()

#region virtuals

## Returns the object's texture.
## [br][br][b]Note:[/b] This object is a [Texture2D] by itself, so if can be used as
## a texture. This method simply returns the underlying [Texture2D] instance.
func get_texture() -> Texture2D:
	if not _texture:
		_texture = _get_texture()
		_texture.changed.connect(emit_changed)
	return _texture


## Called when this object's [Texture2D] is queried.
## [br][br]After this is called, the texture is cached and this method is not called
## anymore on this object.
func _get_texture() -> Texture2D:
	return null


## Returns this object's [Material], to be applied whenever its texture is used.
func get_material() -> Material:
	if _material:
		return _material
	
	var override := _get_material()
	if override:
		_material = override
		return override
	
	var palette := get_palette()
	if palette:
		var shader := ShaderMaterial.new()
		shader.shader = preload("res://Scenes/StageScene/Board/CellObject.gdshader")
		shader.set_shader_parameter("palette", palette)
		shader.set_shader_parameter("palette_enabled", true)
		_material = shader
		return shader
	
	return null


## Virtual method to override this object's material. If a value other than [code]null[/code]
## is returned, any other [Material] will be overridden by the returned one.
## [br][br][b]Note:[/b] If [method _get_palette] does not return [code]null[/code],
## that value will be used by default. However, this method will override that [Material]
## if it does not return [code]null[/code].
func _get_material() -> Material:
	return null


## Returns the object's color palette, to be inserted into the cell's shader.
func get_palette() -> Texture2D:
	return _get_palette()


## Virtual method to override the object's color palette, to be inserted into the cell's shader.
func _get_palette() -> Texture2D:
	return null


## Returns the texture's animation frame duration, or [code]NAN[/code] if it does not have an animation.
func get_animation_delta() -> float:
	return _get_animation_delta()


## Virtual method. Should return the texture's animation frame duration, or [code]NAN[/code]
## if it does not have an animation.
func _get_animation_delta() -> float:
	return NAN


## Notifies this object that the player has interacted (left-click or Q) with it.
func notify_interacted() -> void:
	_interact()
	
	_hover()


## Virtual method to react to this object being interacted with.
func _interact() -> void:
	pass


## Notifies this object aht the player used secondary interact (right-click or E) on this object.
func notify_secondary_interacted() -> void:
	_secondary_interact()


## Virtual method to react to this object being secondary interacted with.
func _secondary_interact() -> void:
	pass


## Notifies this object that the player started hovering over this object.
func notify_hovered() -> void:
	_hover()


## Virtual method to react to being hovered. Called when the player starts hovering
## over this object. Also called when the player interacts with this object.
func _hover() -> void:
	pass


## Notifies this object that the player stopped hovering over this object.
func notify_unhovered() -> void:
	_unhover()


## Virtual method to react to the player stopping hovering over this object.
func _unhover() -> void:
	pass


## Kills this object.
func kill() -> void:
	clear()
	
	_kill()


## Virtual method to react to being killed.
func _kill() -> void:
	pass


## Trigger any effects that occur when this object is revealed. If the player actively
## opened the cell, typically by directly opening this cell or chording an adjacent
## cell, [code]active[/code] should be [code]true[/code]. Otherwise, [code]active[/code]
## should be [code]false[/code].
func notify_revealed(active: bool) -> void:
	_reveal()
	
	if active:
		notify_revealed_active()
	else:
		notify_revealed_passive()


## Virtual method to react to this object being revealed by any means. This is called
## [b]before[/b] [method _reveal_active] or [method _reveal_passive].
func _reveal() -> void:
	pass


## Trigger any effects that occur when this object is actively revealed, typically
## by directly opening this cell or chording an adjacent cell.
func notify_revealed_active() -> void:
	_reveal_active()
	
	Effects.object_revealed(self, true)


## Virtual method to react to this object being revealed. Called when the player
## actively reveals this object, typically by directly opening this cell or chording
## an adjacent cell.
func _reveal_active() -> void:
	pass


## Called when the player passively reveals this object, typically by using
## items or other abilities.
func notify_revealed_passive() -> void:
	_reveal_passive()
	
	Effects.object_revealed(self, false)


## Virtual method to react to being passively revealed. Called when the player passively
## reveals this object, typically by using items or other abilities.
func _reveal_passive() -> void:
	pass


## Returns this object's score value for the charitable reward.
func get_charitable_amount() -> int:
	return _get_charitable_amount()


## Virtual method. Called at the end of a stage when determining the charitable score.
## Should return the amount of points this object gives.
func _get_charitable_amount() -> int:
	return 0


## Returns whether this object is charitable, i.e. whether this object's charitable
## value should be considered when determining the player's charitable score.
func is_charitable() -> bool:
	return _is_charitable()


## Virtual method. Called at the end of a stage when determining the charitable score.
## Should return [code]true[/code] if this object gives any charitable score,
## or [code]false[/code] if not.
func _is_charitable() -> bool:
	return false


## Animates this object's texture.
func animate(time: float) -> void:
	_animate(time)


## Virtual method. Called when this object's texture (see [method get_texture]) is used somewhere.
## This method should be overridden to animate the texture.
## [br][br]If this method is not overridden, nothing happens and the texture does not
## animate.
@warning_ignore("unused_parameter")
func _animate(time: float) -> void:
	pass


## Resets all properties modified by this object. This should be called when the object
## is removed from its [Cell].
func reset() -> void:
	_reset()


## Virtual method. Called when this object is removed from its [Cell]. Should
## reset all properties modified by this object that should not persist.
func _reset() -> void:
	pass

#endregion

#region utilities

func get_quest() -> Quest:
	return Quest.get_current()


func get_inventory() -> QuestInventory:
	return get_quest().get_inventory()


func get_stats() -> QuestStats:
	return get_quest().get_stats()


func get_items() -> Array[Item]:
	var items: Array[Item] = []
	for i in get_inventory().get_item_count():
		items.append(get_inventory().get_item(i))
	return items


func life_restore(life: int, source: Object = self) -> void:
	get_stats().life_restore(life, source)


func life_lose(life: int, source: Object = self) -> void:
	get_stats().life_lose(life, source)


func tween_texture_to(position: Vector2, duration: float = 0.4) -> Tween:
	var start_pos := get_cell().get_global_transform_with_canvas().origin + get_cell().size * get_cell().get_global_transform_with_canvas().get_scale() / 2
	var sprite := Stage.get_current().get_scene().tween_texture(self, start_pos, position, duration, get_cell().get_object_texture_rect().material)
	sprite.material = get_material()
	var tween := sprite.create_tween()
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	return tween

#endregion
