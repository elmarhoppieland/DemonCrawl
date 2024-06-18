extends CanvasLayer

## Cursor to show the currently selected node.

# ==============================================================================
var focused_node: Node ## The node that is currently focused.
var saved_focus: Node ## A saved copy of the focused node. A focus can be saved using [method save_current] and loaded using [method load_saved].
# ==============================================================================
@onready var _focus: MarginContainer = %MarginContainer
# ==============================================================================

func _ready() -> void:
	%AnimationPlayer.play("idle")
	hide()


func _process(_delta: float) -> void:
	if not is_instance_valid(focused_node):
		hide()


## Moves the cursor to the given [code]node[/code]. If another node was selected,
## moves the cursor to the node as an animation.
func move_to(node: Node, force_instant: bool = false) -> void:
	if not force_instant and is_instance_valid(focused_node) and visible:
		create_tween().tween_property(_focus, "global_position", node.global_position, 0.2)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	else:
		_focus.global_position = node.global_position
	
	show()
	focused_node = node


## Save the currently focused node. A saved node can be refocused using [method load_saved].
func save_current() -> void:
	saved_focus = focused_node


## Focuses on the node saved via [method save_current].
func load_saved() -> void:
	move_to(saved_focus, true)
