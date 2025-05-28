extends TokenShopLevelReward
class_name Tokeneer

# ==============================================================================
const WEIGHT_FACTOR := 1.1
# ==============================================================================

#func _apply() -> void:
	#for item in preload("res://Assets/LootTables/Loot.tres").items:
		#if item.value.base_script == Token:
			#item.weight *= (WEIGHT_FACTOR ** level)
			#break
