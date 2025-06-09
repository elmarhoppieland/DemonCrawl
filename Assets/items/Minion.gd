@tool
extends Item

# ==============================================================================

func use() -> void:
	if not StageInstance.has_current():
		return
	
	StageInstance.get_current().solve_cell()
	
	clear()


func damage(amount: int, source: Object) -> int:
	if source is Monster:
		clear()
		source.kill()
		return amount - 1
	
	return amount
