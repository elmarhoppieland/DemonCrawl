@tool
extends Orb
class_name Bubble

# ==============================================================================
const BUBBLE_SPRITE := preload("res://Assets/Scripts/Orbs/BubbleSprite.tscn")
# ==============================================================================

func _init(object: CellObject = null) -> void:
	if object.is_inside_tree():
		position = object.get_cell().get_screen_position()
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
