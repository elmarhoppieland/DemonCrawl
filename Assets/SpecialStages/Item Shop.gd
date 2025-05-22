extends SpecialStage
class_name ItemShop

# ==============================================================================

func _get_name() -> String:
	return tr("STAGE_ITEM_SHOP")


func _get_bg() -> Texture2D:
	return preload("res://Assets/Backgrounds/item_shop.png")


func _get_icon() -> Texture2D:
	return preload("res://Assets/Sprites/SpecialIcon/Item Shop.png")


func _get_icon_small() -> Texture2D:
	return preload("res://Assets/Sprites/SpecialIcon/Item Shop_small.png")


func _get_dest_scene() -> PackedScene:
	return preload("res://Engine/Scenes/SpecialStages/Item Shop.tscn")
