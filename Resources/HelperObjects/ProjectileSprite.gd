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
	match projectile.direction:
		Vector2i.LEFT:
			if global_position.x > get_bounds().end.x:
				return true
		Vector2i.RIGHT:
			if global_position.x < get_bounds().position.x:
				return true
		Vector2i.UP:
			if global_position.y > get_bounds().end.y:
				return true
		Vector2i.DOWN:
			if global_position.y < get_bounds().position.y:
				return true
	
	return get_bounds().intersects(Rect2(global_position, projectile.get_size()))


func _has_left_bounds() -> bool:
	return _was_in_bounds and not is_in_bounds()


func screen_wrap() -> void:
	position -= (get_bounds().size + projectile.get_size()) * Vector2(projectile.direction)
