@tool
extends ConsumableItem

# ==============================================================================

func _use() -> void:
	for cell in await target_cell():
		#target.enchant(BananaPeelEnchant)
		pass


func _invoke() -> void:
	for cell in target_random(1):
		#target.enchant(BananaPeelEnchant)
		pass


func _can_use() -> bool:
	return super() and get_quest().has_current_stage()


#class BananaPeelEnchant extends CellEnchantment:
	#func turn() -> void:
		#if cell.cell_object:
			#cell.cell_object.kill()
