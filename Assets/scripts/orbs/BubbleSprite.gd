extends OrbSprite
class_name BubbleSprite

# ==============================================================================
@onready var _cell_object_texture_rect: CellObjectTextureRect = %CellObjectTextureRect
@onready var _shape: CircleShape2D = %CollisionShape2D.shape
# ==============================================================================

func _ready() -> void:
	_cell_object_texture_rect.object = orb.object


func _clicked() -> void:
	if Stage.has_current():
		var board := Stage.get_current().get_board()
		var cell := board.get_cell_at_global(board.get_global_mouse_position())
		if not cell:
			return
		cell.spawn_instance(orb.object)
		Quest.get_current().get_orb_manager().orbs.erase(orb)
		queue_free()


func _get_size() -> Vector2:
	return _shape.get_rect().size


func _is_hovered() -> bool:
	return get_local_mouse_position().distance_squared_to(Vector2.ZERO) < _shape.radius ** 2
