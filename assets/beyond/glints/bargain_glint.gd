extends Glint

# ==============================================================================
const ITEM_SHOP := preload("res://assets/special_stages/item_shop/item_shop.tres")
# ==============================================================================

func _quest_start() -> void:
	get_quest().add_stage(ITEM_SHOP.generate(), 0)
