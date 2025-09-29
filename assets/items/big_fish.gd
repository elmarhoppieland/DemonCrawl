@tool
extends ConsumableItem

# ==============================================================================
const LIFE_RESTORE_AMOUNT := 3
# ==============================================================================

func _use() -> void:
	for cell in await target_cell():
		if cell.get_aura() is Burning:
			cell.clear_aura()
			life_restore(LIFE_RESTORE_AMOUNT, self)


func _invoke() -> void:
	for cell in target_random(1):
		if cell.get_aura() is Burning:
			cell.clear_aura()
			life_restore(LIFE_RESTORE_AMOUNT, self)


func _can_use() -> bool:
	return super() and get_quest().has_current_stage()
