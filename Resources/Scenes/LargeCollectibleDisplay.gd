@tool
extends MarginContainer
class_name LargeCollectibleDisplay

# ==============================================================================
@export var offer_price := -1 :
	set(value):
		offer_price = value
		
		if not is_node_ready():
			await ready
		
		if offer_price < 0:
			_coin_value.hide()
			return
		_coin_value.show()
		
		_coin_value.coin_value = offer_price
@export var show_focus := true
# ==============================================================================
@export var collectible: Collectible :
	set(value):
		collectible = value
		
		if not is_node_ready():
			await ready
		
		_collectible_display.set_collectible(value)
# ==============================================================================
@onready var _collectible_container: MarginContainer = %CollectibleContainer
@onready var _collectible_display: CollectibleDisplay = %CollectibleDisplay
@onready var _coin_value: CoinValue = %CoinValue
# ==============================================================================
signal interacted()
# ==============================================================================

func interact() -> void:
	Focus.move_to(_collectible_container)
	interacted.emit()


## Creates a new instance of the scene.
static func create(_collectible: Collectible) -> LargeCollectibleDisplay:
	var instance: LargeCollectibleDisplay = load("res://Resources/Scenes/LargeCollectibleDisplay.tscn").instantiate()
	instance.collectible = _collectible
	return instance


func _on_collectible_display_interacted() -> void:
	if show_focus:
		interact()
