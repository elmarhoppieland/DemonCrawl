extends CanvasLayer

## Cursor to show the currently selected node.

# ==============================================================================
## The node that is currently focused.
var focused_node: Node
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
func move_to(node: Node) -> void:
	if is_instance_valid(focused_node):
		create_tween().tween_property(_focus, "global_position", node.global_position, 0.2)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	else:
		_focus.global_position = node.global_position
	
	show()
	focused_node = node
