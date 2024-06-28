extends Control
class_name ItemShopStage

# ==============================================================================
static var selected_item: Item ## The currently selected item.
# ==============================================================================
var _selected_display: CollectibleDisplay
# ==============================================================================
@onready var _offers_container: HBoxContainer = %OffersContainer
@onready var _buy_button: DCButton2 = %BuyButton
# ==============================================================================

func _ready() -> void:
	Foreground.fade_in(1.0)
	
	var items := _get_items()
	selected_item = items[0]
	for item in items:
		var display := CollectibleDisplay.create(item)
		display.offer_price = int(item.data.cost * RNG.randf_range(0.7, 1.3))
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
			
			_buy_button.modulate.a = float(display.offer_price <= Stats.coins)
		)


func _get_items() -> Array[Item]:
	return ItemDB.get_random_item_set(maxi(Stats.coins, 10), EffectManager.propagate_posnum("get_shop_item_count", [], 3), 1)


func _on_buy_button_pressed() -> void:
	if not selected_item:
		return
	if _selected_display.offer_price > Stats.coins:
		return
	
	Stats.spend_coins(_selected_display.offer_price, self)
	
	_selected_display.detach_item_node()
	Inventory.gain_item(selected_item, true)
	
	selected_item = null
	_buy_button.modulate.a = 0


func _on_leave_button_pressed() -> void:
	StagesOverview.selected_stage.completed = true
	get_tree().change_scene_to_file("res://Scenes/StageSelect/StageSelect.tscn")
