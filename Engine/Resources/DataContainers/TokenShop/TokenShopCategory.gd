@tool
extends Resource
class_name TokenShopCategory

# ==============================================================================
@export var name := ""
@export var icon: Texture2D = null
@export var items: Array[TokenShopItemBase] = []
# ==============================================================================
