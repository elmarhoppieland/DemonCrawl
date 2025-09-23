@tool
extends CellObjectTextureRectBase
class_name BubbleObjectTextureRect

# ==============================================================================
@export var object: CellObject :
	set(value):
		object = value
		_update()
		if not is_node_ready():
			await ready
		reset_size()
		position = -object.get_size() * 0.5 if object else Vector2.ZERO
# ==============================================================================

func _get_texture() -> Texture2D:
	return object.get_texture() if object else null


func _get_material() -> Material:
	return object.get_material() if object else null
