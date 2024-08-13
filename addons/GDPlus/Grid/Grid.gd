extends RefCounted

# ==============================================================================
var _grid_size := Vector2i.ZERO
# ==============================================================================

func _init(grid_size: Vector2i = Vector2i.ZERO) -> void:
	_grid_size = grid_size


func set_grid_size(grid_size: Vector2i) -> GDPlus.Grid:
	_grid_size = grid_size
	return self


func get_size() -> Vector2i:
	return _grid_size


func get_width() -> int:
	return _grid_size.x


func get_height() -> int:
	return _grid_size.y


func area() -> int:
	return _grid_size.x * _grid_size.y


func index_to_position(index: int) -> Vector2i:
	return Vector2i(index % _grid_size.x, index / _grid_size.x)


func position_to_index(position: Vector2i) -> int:
	return position.x + position.y * _grid_size.x


func has(point: Vector2i) -> bool:
	if point.x < 0 or point.y < 0:
		return false
	if point.x >= get_width() or point.y >= get_height():
		return false
	return true


func has_index(index: int) -> bool:
	return index < area()
