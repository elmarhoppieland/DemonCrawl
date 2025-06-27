@tool
extends Resource
class_name Registry

# ==============================================================================
@export var masteries: Array[Mastery] = []
@export var mastery_unlockers: Array[MasteryUnlocker] = []

@export var difficulties: Array[Difficulty] = []

@export var token_shop_categories: Array[TokenShopCategoryBase] = []
# ==============================================================================
