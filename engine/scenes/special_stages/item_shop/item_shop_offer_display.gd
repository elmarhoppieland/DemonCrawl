@tool
extends VBoxContainer
class_name ItemShopOfferDisplay

# ==============================================================================
@export var offer: Item = null :
	set(value):
		offer = value
		
		if not is_node_ready():
			await ready
		
		_collectible_display.collectible = value
@export var price := 0 :
	set(value):
		price = value
		
		if not is_node_ready():
			await ready
		
		_coin_value.coin_value = value
# ==============================================================================
@onready var _frame: Frame = %Frame
@onready var _collectible_display: CollectibleDisplay = %CollectibleDisplay
@onready var _coin_value: CoinValue = %CoinValue
# ==============================================================================
signal interacted()
# ==============================================================================

func _ready() -> void:
	_frame.interacted.connect(interacted.emit)
	
	if get_index() == 0:
		_frame.interact.call_deferred()
