@tool
extends Resource
class_name Registry

# ==============================================================================
@export var masteries: Array[MasteryData] = []
@export var mastery_unlockers: Array[MasteryUnlockerData] = []

@export var difficulties: Array[Difficulty] = []

@export var token_shop_categories: Array[TokenShopCategoryBase] = []

@export var auras: Array[Script] = []

@export var items: Array[ItemData] = []
# ==============================================================================

func get_elemental_auras() -> Array[Aura]:
	var elemental_auras: Array[Aura] = []
	for aura in auras:
		if aura.is_elemental():
			elemental_auras.append(aura)
	return elemental_auras
