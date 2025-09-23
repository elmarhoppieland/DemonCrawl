extends Control
class_name ItemShopStage

# ==============================================================================
const OFFER_DISPLAY := preload("res://engine/scenes/special_stages/item_shop/item_shop_offer_display.tscn")
# ==============================================================================
var _selected_display: ItemShopOfferDisplay
# ==============================================================================
@onready var _offers_container: HBoxContainer = %OffersContainer
@onready var _buy_button: DCButton = %BuyButton
# ==============================================================================
signal finished()
# ==============================================================================

func _ready() -> void:
	#Foreground.fade_in(1.0)
	
	var items := _get_items()
	if items.is_empty():
		return
	
	for data in items:
		var item := data.create()
		var frame: ItemShopOfferDisplay = OFFER_DISPLAY.instantiate()
		frame.offer = item
		frame.add_child(item)
		frame.price = maxi(int(item.get_cost() * randf_range(0.7, 1.3)), 1)
		_offers_container.add_child(frame)
		
		frame.interacted.connect(func() -> void:
			_selected_display = frame
			
			if frame.offer == null:
				_buy_button.modulate.a = 0
				return
			
			_buy_button.modulate.a = float(frame.price <= Quest.get_current().get_stats().coins)
		)


func _get_items() -> Array[ItemData]:
	return Quest.get_current().get_item_pool().create_filter()\
		.set_max_cost(maxi(Quest.get_current().get_stats().coins, 10))\
		.set_min_cost(1)\
		.get_random_item_set(3) # TODO: propagate through EffectManager


func _on_buy_button_pressed() -> void:
	if not _selected_display:
		return
	if not _selected_display.offer:
		return
	if _selected_display.price > Quest.get_current().get_stats().coins:
		return
	
	Quest.get_current().get_stats().spend_coins(_selected_display.price, self)
	
	var item := _selected_display.offer
	_selected_display.remove_child(item)
	_selected_display.offer = null
	Quest.get_current().get_inventory().item_gain(item)
	
	#selected_item = null
	_buy_button.modulate.a = 0


func _on_leave_button_pressed() -> void:
	finished.emit()
	get_tree().change_scene_to_file("res://engine/scenes/stage_select/stage_select.tscn")
