@tool
extends Control
class_name BazaarScene

# ==============================================================================
@export var instance: BazaarInstance :
	set(value):
		var old := instance
		instance = value
		
		_update(old)
# ==============================================================================
var _selected_offer: BazaarInstance.ItemOfferBase :
	set(value):
		_selected_offer = value
		if not is_node_ready():
			await ready
		_buy_button.modulate.a = float(value.can_afford())
# ==============================================================================
@onready var _buy_display: CollectibleDisplay = %BuyDisplay
@onready var _buy_coin_value: CoinValue = %BuyCoinValue
@onready var _sell_display: CollectibleDisplay = %SellDisplay
@onready var _sell_coin_value: CoinValue = %CoinValue
@onready var _trade_display: CollectibleDisplay = %TradeDisplay
@onready var _trade_cost_display: TextureNodeDisplay = %TradeCostDisplay
@onready var _buy_button: DCButton = %BuyButton
# ==============================================================================

func _update(old_instance: BazaarInstance) -> void:
	if not is_node_ready():
		await ready
	
	if old_instance:
		var old_buy_offer := old_instance.get_buy_offer()
		old_buy_offer.child_order_changed.disconnect(_update_item.bind(old_buy_offer, _buy_display))
		old_buy_offer.get_quest().get_stats().changed.disconnect(_update_font_color.bind(old_buy_offer, _buy_coin_value))
		old_buy_offer.changed.disconnect(_update_price.bind(old_buy_offer, _buy_coin_value))
		old_buy_offer.changed.disconnect(_update_font_color.bind(old_buy_offer, _buy_coin_value))
		
		var old_sell_offer := old_instance.get_sell_offer()
		old_sell_offer.child_order_changed.disconnect(_update_item.bind(old_sell_offer, _sell_display))
		old_sell_offer.changed.disconnect(_update_price.bind(old_sell_offer, _sell_coin_value))
		
		var old_trade_offer := old_instance.get_trade_offer()
		old_trade_offer.child_order_changed.disconnect(_update_item.bind(old_trade_offer, _trade_display))
	
	if not instance:
		return
	
	var buy_offer := instance.get_buy_offer()
	_update_item(buy_offer, _buy_display)
	buy_offer.child_order_changed.connect(_update_item.bind(buy_offer, _buy_display))
	_update_font_color(buy_offer, _buy_coin_value)
	buy_offer.get_quest().get_stats().changed.connect(_update_font_color.bind(buy_offer, _buy_coin_value))
	buy_offer.changed.connect(_update_font_color.bind(buy_offer, _buy_coin_value))
	_update_price(buy_offer, _buy_coin_value)
	buy_offer.changed.connect(_update_price.bind(buy_offer, _buy_coin_value))
	
	var sell_offer := instance.get_sell_offer()
	_update_item(sell_offer, _sell_display)
	sell_offer.child_order_changed.connect(_update_item.bind(sell_offer, _sell_display))
	_update_price(sell_offer, _sell_coin_value)
	sell_offer.changed.connect(_update_price.bind(sell_offer, _sell_coin_value))
	
	var trade_offer := instance.get_trade_offer()
	_update_item(trade_offer, _trade_display)
	trade_offer.child_order_changed.connect(_update_item.bind(trade_offer, _trade_display))
	_update_trade_cost(trade_offer, _trade_cost_display)
	trade_offer.changed.connect(_update_trade_cost.bind(trade_offer, _trade_cost_display))


func _update_item(offer: BazaarInstance.ItemOfferBase, display: CollectibleDisplay) -> void:
	display.collectible = offer.get_item()


func _update_price(offer: BazaarInstance.PricedItemOffer, coin_value: CoinValue) -> void:
	coin_value.coin_value = offer.cost


func _update_trade_cost(offer: BazaarInstance.TradeItemOffer, cost_display: TextureNodeDisplay) -> void:
	cost_display.display_as_child(offer.cost.create() if offer.cost else null)


func _update_font_color(offer: BazaarInstance.ItemOfferBase, coin_value: CoinValue) -> void:
	coin_value.color = Color.WHITE if offer.can_afford() else Color.RED


func _on_buy_frame_interacted() -> void:
	_selected_offer = instance.get_buy_offer()


func _on_sell_frame_interacted() -> void:
	_selected_offer = instance.get_sell_offer()


func _on_trade_frame_interacted() -> void:
	_selected_offer = instance.get_trade_offer()


func _on_buy_button_pressed() -> void:
	if _selected_offer.can_afford():
		_selected_offer.perform()


func _on_leave_button_pressed() -> void:
	instance.finish()
