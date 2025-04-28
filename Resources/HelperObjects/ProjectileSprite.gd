@tool
extends Sprite2D
class_name ProjectileSprite

# ==============================================================================
const Z_INDEX := 5
# ==============================================================================
@export var projectile: Projectile
# ==============================================================================
var _was_in_bounds := false
# ==============================================================================

@warning_ignore("shadowed_variable")
func _init(projectile: Projectile = null) -> void:
	self.projectile = projectile
	
	z_index = Z_INDEX


func _validate_property(property: Dictionary) -> void:
	if property.name == &"texture":
		property.usage &= ~PROPERTY_USAGE_EDITOR & ~PROPERTY_USAGE_STORAGE


func _process(delta: float) -> void:
	var old_global_position := global_position
	
	position += projectile.get_speed() * projectile.direction * delta
	
	var board := Stage.get_current().get_board()
	var old_cell := board.get_cell_at_global(old_global_position)
	var new_cell := board.get_cell_at_global(global_position)
	
	if old_cell != new_cell and new_cell != null:
		projectile.notify_cell_entered(new_cell)
	
	if _has_left_bounds():
		projectile.notify_screen_exited()
	
	_was_in_bounds = is_in_bounds()


func get_bounds() -> Rect2:
	var board := Stage.get_current().get_board()
	var camera := board.get_camera()
	
	var camera_center := camera.get_screen_center_position()
	var half_size := get_viewport_rect().size / camera.zoom * 0.5
	
	return board.get_global_rect().expand(camera_center - half_size).expand(camera_center + half_size)


func is_in_bounds() -> bool:
	return get_bounds().grow_side(get_origin_side(), INF).intersects(Rect2(global_position, projectile.get_size()))


func get_origin_side() -> Side:
	match projectile.direction:
		Vector2i.LEFT:
			return SIDE_RIGHT
		Vector2i.UP:
			return SIDE_BOTTOM
		Vector2i.RIGHT:
			return SIDE_LEFT
		Vector2i.DOWN:
			return SIDE_TOP
		_:
			return SIDE_BOTTOM


func _has_left_bounds() -> bool:
	return _was_in_bounds and not is_in_bounds()


func screen_wrap() -> void:
	position -= (get_bounds().size + projectile.get_size()) * Vector2(projectile.direction)
