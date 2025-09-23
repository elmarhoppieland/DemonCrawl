@tool
extends Book

# ==============================================================================

func _activate() -> void:
	get_stage_instance().solve_cell()
