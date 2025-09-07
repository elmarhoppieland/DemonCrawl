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
# ==============================================================================

func _is_visible() -> bool:
	return object != null


func _get_texture() -> Texture2D:
	return object.get_texture()


func _get_material() -> Material:
	return object.get_material()
