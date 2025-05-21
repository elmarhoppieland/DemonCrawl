@tool
extends Label
class_name CellValueLabel

# ==============================================================================
@export var mode := Cell.Mode.INVALID :
	set(new_mode):
		mode = new_mode
		if not is_node_ready():
			await ready
		visible = new_mode == Cell.Mode.VISIBLE and value != 0 and not occupied
@export var value := 0 :
	set(new_value):
		value = new_value
		if not is_node_ready():
			await ready
		visible = mode == Cell.Mode.VISIBLE and new_value != 0 and not occupied
		text = str(new_value)
@export var occupied := false :
	set(new_occupied):
		occupied = new_occupied
		if not is_node_ready():
			await ready
		visible = mode == Cell.Mode.VISIBLE and value != 0 and not new_occupied
# ==============================================================================
