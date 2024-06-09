extends Label

# ==============================================================================

func _process(_delta: float) -> void:
	text = str(Board.get_time())
