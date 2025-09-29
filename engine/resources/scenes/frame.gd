@tool
extends MarginContainer
class_name Frame

# ==============================================================================
@export var show_focus := true
# ==============================================================================
var _content: CanvasItem : get = get_content
# ==============================================================================
signal interacted()
# ==============================================================================

func interact() -> void:
	Focus.move_to(self)
	interacted.emit()


## Creates a new instance of the scene.
@warning_ignore("shadowed_variable")
static func create(content: CanvasItem) -> Frame:
	var instance: Frame = load("res://engine/resources/scenes/frame.tscn").instantiate()
	instance._content = content
	instance.add_child(content)
	return instance


func get_content() -> CanvasItem:
	return _content


func _on_interacted() -> void:
	if show_focus:
		interact()
