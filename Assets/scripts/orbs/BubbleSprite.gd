extends OrbSprite
class_name BubbleSprite

# ==============================================================================
@onready var _cell_object_texture_rect: CellObjectTextureRect = %CellObjectTextureRect
@onready var _shape: CircleShape2D = %CollisionShape2D.shape
# ==============================================================================

func _ready() -> void:
	_cell_object_texture_rect.object = orb.get_object()


func _clicked() -> void:
	if orb.get_quest().has_current_stage():
		var board := orb.get_quest().get_current_stage().get_board()
		var cell_node := board.get_cell_at_global(board.get_global_mouse_position())
		if cell_node == null:
			return
		var cell := cell_node.get_data()
		if not cell or cell.is_hidden() or cell.is_occupied():
			return
		var object: CellObject = orb.get_object()
		orb.remove_child(object)
		cell.add_child(object)
		orb.queue_free()
		queue_free()


func _get_size() -> Vector2:
	return _shape.get_rect().size


func _is_hovered() -> bool:
	return get_local_mouse_position().distance_squared_to(Vector2.ZERO) < _shape.radius ** 2
