extends Control
class_name ItemShopStage

# ==============================================================================
var _selected_display: LargeCollectibleDisplay
# ==============================================================================
@onready var _offers_container: HBoxContainer = %OffersContainer
@onready var _buy_button: DCButton = %BuyButton
# ==============================================================================

func _ready() -> void:
	#Foreground.fade_in(1.0)
	
	var items := _get_items()
	if items.is_empty():
		return
	
	for item in items:
		var display := LargeCollectibleDisplay.create(item)
		display.offer_price = maxi(int(item.get_cost() * randf_range(0.7, 1.3)), 1)
		_offers_container.add_child(display)
		
		display.interacted.connect(func() -> void:
			_selected_display = display
			
			if display.collectible == null:
				_buy_button.modulate.a = 0
				return
			
			_buy_button.modulate.a = float(display.offer_price <= Quest.get_current().get_instance().coins)
		)
	
	_offers_container.get_child(0).interact.call_deferred()


func _get_items() -> Array[Item]:
	return ItemDB.create_filter().set_max_cost(maxi(Quest.get_current().get_instance().coins, 10)).set_min_cost(1).get_random_item_set(Effects.get_shop_item_count(3))


func _on_buy_button_pressed() -> void:
	if not _selected_display.collectible:
		return
	if _selected_display.offer_price > Quest.get_current().get_instance().coins:
		return
	
	Quest.get_current().get_instance().spend_coins(_selected_display.offer_price, self)
	
	var item := _selected_display.collectible
	_selected_display.collectible = null
	Quest.get_current().get_instance().item_gain(item)
	
	#selected_item = null
	_buy_button.modulate.a = 0


func _on_leave_button_pressed() -> void:
	Stage.get_current().finish()
	Stage.clear_current()
	get_tree().change_scene_to_file("res://Scenes/StageSelect/StageSelect.tscn")
