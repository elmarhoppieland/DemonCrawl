@tool
extends SpecialStage
class_name ItemShop

# ==============================================================================

func _get_name() -> String:
	return tr("stages.special.item-shop")


func _get_bg() -> Texture2D:
	return preload("res://assets/backgrounds/item_shop.png")


func _get_large_icon() -> Texture2D:
	return preload("res://assets/sprites/special_icon/item_shop.png")


func _get_small_icon() -> Texture2D:
	return preload("res://assets/sprites/special_icon/item_shop_small.png")


func _get_dest_scene() -> PackedScene:
	return preload("res://engine/scenes/special_stages/item_shop/item_shop.tscn")
