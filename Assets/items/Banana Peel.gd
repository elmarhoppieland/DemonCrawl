@tool
extends Item

# ==============================================================================

func _use() -> void:
	var target := await target_cell()
	if not target:
		return
	
	#target.enchant(BananaPeelEnchant)
	
	clear()


#class BananaPeelEnchant extends CellEnchantment:
	#func turn() -> void:
		#if cell.cell_object:
			#cell.cell_object.kill()
