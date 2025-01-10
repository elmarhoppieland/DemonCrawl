@tool
extends AnnotatedTexture
class_name CellObject

## A [Cell]'s object.

# ==============================================================================
@export var _cell_position := Vector2i.ZERO ## The board position of the [Cell] this is the object of.
@export var _stage: Stage : get = get_stage
# ==============================================================================
var _texture: Texture2D : get = get_texture
# ==============================================================================

#region internals

func _init(cell_position: Vector2i = Vector2i.ZERO, stage: Stage = null) -> void:
	_cell_position = cell_position
	_stage = stage
	assert(stage != null)


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
	return get_stage().get_board().get_cell(_cell_position)


func get_tree() -> SceneTree:
	return Engine.get_main_loop()


func get_stage() -> Stage:
	return _stage


## Clears this [CellObject], setting the cell's [member Cell.cell_object] to [code]null[/code].
func clear() -> void:
	get_cell().clear_object()
	
	get_cell()._object_texture.tooltip_grabber.text = ""
	get_cell()._object_texture.tooltip_grabber.subtext = ""


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

#region utilities

func get_quest() -> Quest:
	return Quest.get_current()


func get_quest_instance() -> QuestInstance:
	return get_quest().get_instance()


func get_items() -> Array[Item]:
	var items: Array[Item] = []
	for i in get_quest_instance().get_item_count():
		items.append(get_quest_instance().get_item(i))
	return items


func life_restore(life: int, source: Object = self) -> void:
	get_quest_instance().life_restore(life, source)


func life_lose(life: int, source: Object = self) -> void:
	get_quest_instance().life_lose(life, source)

#endregion
