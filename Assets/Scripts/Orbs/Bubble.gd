@tool
extends Orb
class_name Bubble

# ==============================================================================
const BUBBLE_SPRITE := preload("res://Assets/Scripts/Orbs/BubbleSprite.tscn")
# ==============================================================================

func _init(object: CellObject = null) -> void:
	if object.is_inside_tree():
		var board := object.get_stage_instance().get_board()
		position = board.get_viewport_transform() * board.get_global_at_cell_position(object.get_cell().get_position())
		object.reparent(self)
	else:
		add_child(object)


func _export_packed() -> Array:
	return [get_object()]


func _create_sprite() -> BubbleSprite:
	return BUBBLE_SPRITE.instantiate()


func get_object() -> CellObject:
	for child in get_children():
		if child is CellObject:
			return child
	return null
