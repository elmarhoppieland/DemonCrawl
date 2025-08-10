@tool
extends MarginContainer
class_name Frame

# ==============================================================================
@export var show_focus := true
# ==============================================================================
signal interacted()
# ==============================================================================

func interact() -> void:
	Focus.move_to(self)
	interacted.emit()


## Creates a new instance of the scene.
@warning_ignore("shadowed_variable")
static func create(node: CanvasItem) -> Frame:
	var instance: Frame = load("res://Engine/Resources/Scenes/Frame.tscn").instantiate()
	instance.add_child(node)
	return instance


func _on_interacted() -> void:
	if show_focus:
		interact()
