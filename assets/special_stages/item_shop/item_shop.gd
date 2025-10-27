@tool
extends SpecialStage
class_name ItemShop

# ==============================================================================

func _get_name_id() -> String:
	return "stage.special.item-shop"


func _get_bg() -> Texture2D:
	return preload("res://assets/backgrounds/item_shop.png")


func _get_large_icon() -> Texture2D:
	return preload("res://assets/special_stages/item_shop/item_shop.png")


func _get_small_icon() -> Texture2D:
	return preload("res://assets/special_stages/item_shop/item_shop_small.png")


func _create_instance() -> ItemShopInstance:
	return ItemShopInstance.new()
