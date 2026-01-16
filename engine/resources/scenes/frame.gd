@tool
extends MarginContainer
class_name Frame

# ==============================================================================
@export var show_focus := true
@export var inner_border_color := Color(0.545, 0.545, 0.545) :
	set(value):
		inner_border_color = value
		
		if not is_node_ready():
			await ready
		
		_inner_border_rect.color = value
# ==============================================================================
var _content: CanvasItem : get = get_content
# ==============================================================================
@onready var _inner_border_rect: ColorRect = %InnerBorderRect
# ==============================================================================
signal interacted()
signal second_interacted()
# ==============================================================================

func interact() -> void:
	if show_focus:
		Focus.move_to(self)
	interacted.emit()


func second_interact() -> void:
	second_interacted.emit()


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
	interact()


func _on_second_interacted() -> void:
	second_interact()
