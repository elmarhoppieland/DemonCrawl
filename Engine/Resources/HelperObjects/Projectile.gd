@tool
extends TextureNode
class_name Projectile

# ==============================================================================
@export var position: Vector2 :
	set(value):
		position = value
		if sprite and is_inside_tree():
			sprite.global_position = get_quest().get_current_stage().get_board().get_global_at_cell_position(value)
	get:
		if sprite and is_inside_tree():
			return get_quest().get_current_stage().get_board().get_cell_position_at_global(sprite.global_position)
		return position

@export var direction := Vector2i.ZERO

@export var _speed_override := NAN
# ==============================================================================
var sprite: ProjectileSprite
# ==============================================================================

func get_quest() -> Quest:
	var base := get_parent()
	while base != null and base is not Quest:
		base = base.get_parent()
	return base


func get_stage_instance() -> StageInstance:
	var base := get_parent()
	while base != null and base is not StageInstance:
		base = base.get_parent()
	return base


@warning_ignore("shadowed_variable")
func _init(cell_pos: Vector2i = Vector2i.ZERO, direction: Vector2i = Vector2i.ZERO) -> void:
	if direction == Vector2i.ZERO:
		# pick a random direction
		var i := randi() % 4
		direction[i / 2] = (i % 2) * 2 - 1
	
	self.direction = direction
	self.position = cell_pos


func register() -> void:
	sprite = get_stage_instance().get_scene().register_projectile(self)


func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	if _texture:
		_texture.draw(to_canvas_item, pos, modulate, transpose)


func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	if _texture:
		_texture.draw_rect(to_canvas_item, rect, tile, modulate, transpose)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	if _texture:
		_texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)


func _get_width() -> int:
	if _texture:
		return _texture.get_width()
	return 0


func _get_height() -> int:
	if _texture:
		return _texture.get_height()
	return 0


func _has_alpha() -> bool:
	if _texture:
		return _texture.has_alpha()
	return false


## Virtual method. Should return this [Projectile]'s texture.
func _get_texture() -> Texture2D:
	return null


func get_speed() -> float:
	if is_nan(_speed_override):
		return get_quest().get_current_stage().get_projectile_manager().speed
	return _speed_override


func screen_wrap() -> void:
	sprite.screen_wrap()


func clear() -> void:
	sprite.queue_free()
	get_quest().get_current_stage().get_projectile_manager().clear_projectile(self)


func notify_screen_exited() -> void:
	_screen_exited()


func _screen_exited() -> void:
	screen_wrap()


func notify_cell_entered(cell: CellData) -> void:
	_cell_entered(cell)


@warning_ignore("unused_parameter")
func _cell_entered(cell: CellData) -> void:
	pass
