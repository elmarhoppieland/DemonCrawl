extends NomadSellOffer
class_name NomadSellApplesOffer

# ==============================================================================
@export var amount := -1
# ==============================================================================

func _spawn() -> void:
	amount = randi_range(2, 5)
	cost = roundi(amount * randf_range(3, 7))


func _perform() -> void:
	super()
	
	const APPLE = preload("res://Assets/Items/Apple.tres")
	
	for i in amount:
		_nomad.get_inventory().item_gain(APPLE.create())
