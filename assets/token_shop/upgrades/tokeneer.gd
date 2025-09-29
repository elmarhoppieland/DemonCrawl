extends TokenShopReward

# ==============================================================================
const WEIGHT_FACTOR := 1.1
# ==============================================================================

func _apply() -> void:
	pass
	#for item in preload("res://assets/LootTables/Loot.tres").items:
		#if item.value.base_script == Token:
			#item.weight *= WEIGHT_FACTOR
			#break


func _reapply() -> void:
	_apply()
