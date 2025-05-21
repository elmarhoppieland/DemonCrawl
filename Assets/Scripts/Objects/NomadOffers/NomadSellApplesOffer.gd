extends NomadSellOffer
class_name NomadSellApplesOffer

# ==============================================================================
@export var amount := -1
# ==============================================================================

func _spawn() -> void:
	amount = randi_range(2, 5)
	cost = roundi(amount * randf_range(3, 7))


func _perform() -> void:
	const APPLE = preload("res://Assets/Items/Apple.tres")
	
	super()
	
	for i in amount:
		Quest.get_current().get_inventory().item_gain(APPLE.duplicate())
