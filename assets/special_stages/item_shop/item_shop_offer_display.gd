@tool
extends VBoxContainer
class_name ItemShopOfferDisplay

# ==============================================================================
@export var offer: Item = null :
	set(value):
		offer = value
		_update()
@export var price := 0 :
	set(value):
		price = value
		_update()
@export var stats: QuestStats :
	set(value):
		if stats and stats.changed.is_connected(_update_font_color):
			stats.changed.disconnect(_update_font_color)
		
		stats = value
		
		_update()
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


func _update() -> void:
	if not is_node_ready():
		await ready
	
	_collectible_display.collectible = offer
	
	if price < 0:
		_coin_value.hide()
		return
	
	_coin_value.coin_value = price
	if stats:
		_update_font_color()
		stats.changed.connect(_update_font_color)
	else:
		_coin_value.color = Color.WHITE


func _update_font_color() -> void:
	_coin_value.color = Color.WHITE if stats.coins >= price else Color.RED
