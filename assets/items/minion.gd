@tool
extends ConsumableItem

# ==============================================================================

func _use() -> void:
	if not get_stage_instance():
		return
	
	get_stage_instance().solve_cell()


func damage(amount: int, source: Object) -> int:
	if source is Monster:
		clear()
		source.kill()
		return amount - 1
	
	return amount
