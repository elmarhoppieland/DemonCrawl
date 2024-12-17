extends CanvasLayer

## Cursor to show the currently selected node.

# ==============================================================================
var _focused_node: CanvasItem : set = _set_focused_node, get = get_focused_node ## The node that is currently focused.
#var saved_focus: CanvasItem ## A saved copy of the focused node. A focus can be saved using [method save_current] and loaded using [method load_saved].
# ==============================================================================
@onready var _focus: MarginContainer = %MarginContainer
# ==============================================================================

func _ready() -> void:
	hide()


func _process(_delta: float) -> void:
	if not is_instance_valid(_focused_node):
		hide()


## Moves the cursor to the given [code]node[/code]. If another node was selected,
## moves the cursor to the node as an animation.
func move_to(node: CanvasItem, force_instant: bool = false, size: Vector2 = Vector2.ZERO) -> void:
	if size != Vector2.ZERO:
		_focus.size = size
	elif node.has_method("get_size"):
		_focus.size = node.get_size()
	else:
		_focus.size = Vector2(16, 16)
	
	if not force_instant and is_instance_valid(_focused_node) and visible:
		create_tween().tween_property(_focus, "global_position", node.get_screen_transform().origin, 0.2)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	else:
		_focus.position = node.get_screen_transform().origin
	
	show()
	_focused_node = node


## Save the currently focused node. A saved node can be refocused using [method load_saved].
#func save_current() -> void:
	#saved_focus = _focused_node


## Focuses on the node saved via [method save_current].
#func load_saved() -> void:
	#move_to(saved_focus, true)


func _set_focused_node(focused_node: CanvasItem) -> void:
	_focused_node = focused_node
	if not focused_node:
		breakpoint


func get_focused_node() -> CanvasItem:
	return _focused_node
