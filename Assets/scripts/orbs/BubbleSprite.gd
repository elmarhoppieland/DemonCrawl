extends OrbSprite
class_name BubbleSprite

# ==============================================================================
@onready var _cell_object_texture_rect: CellObjectTextureRect = %CellObjectTextureRect
@onready var _shape: CircleShape2D = %CollisionShape2D.shape
# ==============================================================================

func _ready() -> void:
	_cell_object_texture_rect.object = orb.object


func _clicked() -> void:
	if StageInstance.has_current():
		var board := StageInstance.get_current().get_board()
		var cell_node := board.get_cell_at_global(board.get_global_mouse_position())
		if cell_node == null:
			return
		var cell := cell_node.get_data()
		if not cell or cell.is_hidden() or cell.is_occupied():
			return
		cell.set_object(orb.object)
		Quest.get_current().get_orb_manager().orbs.erase(orb)
		queue_free()


func _get_size() -> Vector2:
	return _shape.get_rect().size


func _is_hovered() -> bool:
	return get_local_mouse_position().distance_squared_to(Vector2.ZERO) < _shape.radius ** 2
