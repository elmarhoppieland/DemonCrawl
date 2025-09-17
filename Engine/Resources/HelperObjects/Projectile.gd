@tool
@abstract
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
