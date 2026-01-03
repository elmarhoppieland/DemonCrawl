@tool
extends Resource
class_name Registry

# ==============================================================================
@export var masteries: Array[MasteryData] = [] ## A list of all available masteries.
@export var mastery_unlockers: Array[MasteryUnlockerData] = [] ## A list of available [MasteryUnlocker]s.

@export var difficulties: Array[Difficulty] = [] ## A list of available difficulties.

@export var token_shop_categories: Array[TokenShopCategoryBase] = [] ## A list of available categories in the Token Shop.

@export var auras: Array[Script] = [] ## A list of available [Aura]s.

@export var items: Array[ItemData] = [] ## A list of available items.

@export var stages: Array[StageFile] = [] ## A list of available stages.
# ==============================================================================

func get_elemental_auras() -> Array[Aura]:
	var elemental_auras: Array[Aura] = []
	for aura in auras:
		if aura.is_elemental():
			elemental_auras.append(aura)
	return elemental_auras
