@tool
extends HBoxContainer
class_name TokenCount

# ==============================================================================
@onready var _label: Label = %TokenLabel
# ==============================================================================

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	
	if not Codex.token_count_changed.is_connected(update):
		Codex.token_count_changed.connect(update)
	update()


func update():
	if not is_node_ready():
		await ready
	
	_label.text = str(Codex.tokens)
