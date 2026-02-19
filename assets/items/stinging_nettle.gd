@tool
extends OmenItem

# ==============================================================================

func _enable() -> void:
	get_inventory().get_effects().item_gained.connect(_on_item_gained)


func _disable() -> void:
	get_inventory().get_effects().item_gained.disconnect(_on_item_gained)


# Reacts to inventory ordering.
func _on_item_gained(_item: Item) -> void:
	get_stats().damage(1, self)
