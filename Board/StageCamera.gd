extends Camera2D

# ==============================================================================
@export var move_speed := 0.0
# ==============================================================================

func _ready() -> void:
	await Board.cells_generated
	
	position = Board.size / 2 * owner.tile_set.tile_size
	
	create_tween().tween_property(self, "zoom", Vector2.ONE, 1).set_trans(Tween.TRANS_QUAD)


func _process(delta: float) -> void:
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position += move_speed * input_vector * delta
	
	var scroll := int(Input.is_action_just_released("zoom_in")) - int(Input.is_action_just_released("zoom_out"))
	if scroll != 0:
		create_tween().tween_property(self, "zoom", (zoom * (1.5 ** scroll)).round(), 0.1)
