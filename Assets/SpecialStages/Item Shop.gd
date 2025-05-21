extends SpecialStage
class_name ItemShop

# ==============================================================================

func _init() -> void:
	type = Type.ITEM_SHOP
	name = "Item Shop"
	bg = preload("res://Assets/Backgrounds/item_shop.png")
	icon = preload("res://Assets/Sprites/SpecialIcon/Item Shop.png")
	icon_small = preload("res://Assets/Sprites/SpecialIcon/Item Shop_small.png")
	
	dest_scene = preload("res://Engine/Scenes/SpecialStages/Item Shop.tscn")


static func _import(value: Dictionary) -> ItemShop:
	var shop := ItemShop.new()
	shop.locked = value.locked
	return shop
