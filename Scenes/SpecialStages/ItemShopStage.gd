extends Control
class_name ItemShopStage

# ==============================================================================
static var selected_item: Item ## The currently selected item.
# ==============================================================================
var _selected_display: CollectibleDisplay
# ==============================================================================
@onready var _offers_container: HBoxContainer = %OffersContainer
@onready var _buy_button: DCButton = %BuyButton
# ==============================================================================

func _ready() -> void:
	#Foreground.fade_in(1.0)
	
	var items := _get_items()
	if items.is_empty():
		return
	
	selected_item = items[0]
	for item in items:
		var display := LargeCollectibleDisplay.create(item)
		display.offer_price = maxi(int(item.data.cost * randf_range(0.7, 1.3)), 1)
		_offers_container.add_child(display)
		
		if item == selected_item:
			(func(): display.focus_grabber.interacted.emit()).call_deferred()
		
		display.focus_grabber.interacted.connect(func():
			_selected_display = display
			
			if display.collectible == null:
				ItemShopStage.selected_item = null
				_buy_button.modulate.a = 0
				return
			
			ItemShopStage.selected_item = item
			
			_buy_button.modulate.a = float(display.offer_price <= Quest.get_current().get_instance().coins)
		)


func _get_items() -> Array[Item]:
	return ItemDB.create_filter().set_max_cost(maxi(Quest.get_current().get_instance().coins, 10)).set_min_cost(1).get_random_item_set(Effects.get_shop_item_count(3))


func _on_buy_button_pressed() -> void:
	if not selected_item:
		return
	if _selected_display.offer_price > Quest.get_current().get_instance().coins:
		return
	
	Quest.get_current().get_instance().spend_coins(_selected_display.offer_price, self)
	
	_selected_display.detach_collectible_node()
	Quest.get_current().get_instance().item_gain(selected_item)
	
	selected_item = null
	_buy_button.modulate.a = 0


func _on_leave_button_pressed() -> void:
	Quest.get_current().get_selected_stage().completed = true
	get_tree().change_scene_to_file("res://Scenes/StageSelect/StageSelect.tscn")
