@tool
extends Control
class_name ItemShopScene

# ==============================================================================
const OFFER_DISPLAY := preload("res://assets/special_stages/item_shop/item_shop_offer_display.tscn")
# ==============================================================================
@export var instance: ItemShopInstance :
	set(value):
		instance = value
		
		_update()
# ==============================================================================
var _selected_display: ItemShopOfferDisplay
# ==============================================================================
@onready var _offers_container: HBoxContainer = %OffersContainer
@onready var _buy_button: DCButton = %BuyButton
# ==============================================================================

func _update() -> void:
	if not is_node_ready():
		await ready
	
	var offers := instance.get_offers()
	for i in maxi(_offers_container.get_child_count(), offers.size()):
		var frame: ItemShopOfferDisplay
		if i < _offers_container.get_child_count():
			frame = _offers_container.get_child(i)
		else:
			frame = OFFER_DISPLAY.instantiate()
			frame.stats = instance.get_quest().get_stats()
			_offers_container.add_child(frame)
			
			frame.interacted.connect(func() -> void:
				_selected_display = frame
				
				if frame.offer == null or frame.offer is ItemFiller:
					_buy_button.modulate.a = 0
					return
				
				_buy_button.modulate.a = float(frame.price <= Quest.get_current().get_stats().coins)
			)
		
		if i < offers.size():
			var offer := offers[i]
			frame.offer = offer.get_item()
			frame.price = offer.cost
		else:
			frame.queue_free()


func _on_buy_button_pressed() -> void:
	if not _selected_display:
		return
	if not _selected_display.offer:
		return
	
	instance.purchase(_selected_display.get_index())
	
	_buy_button.modulate.a = 0
	
	_update()


func _on_leave_button_pressed() -> void:
	instance.finish()
