@tool
extends Resource
class_name Registry

# ==============================================================================
@export var masteries: Array[Mastery] = []
@export var mastery_unlockers: Array[MasteryUnlocker] = []

@export var difficulties: Array[Difficulty] = []

@export var token_shop_categories: Array[TokenShopCategoryBase] = []

@export var auras: Array[Aura] = []
# ==============================================================================

func get_elemental_auras() -> Array[Aura]:
	var elemental_auras: Array[Aura] = []
	for aura in auras:
		if aura.is_elemental():
			elemental_auras.append(aura)
	return elemental_auras
