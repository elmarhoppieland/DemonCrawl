@tool
extends Control
class_name TokenShopCategoryDisplay

# ==============================================================================
@export var category: TokenShopCategory = null :
	set(value):
		category = value
		
		if not is_node_ready():
			await ready
		
		if value == null:
			for child in _items_container.get_children():
				child.queue_free()
		
		var item_display_scene := load("res://Engine/Scenes/TokenShop/TokenShopItemDisplay.tscn") as PackedScene
		
		for item in value.items:
			var item_display := item_display_scene.instantiate() as TokenShopItemDisplay
			item_display.item = item
			
			_items_container.add_child(item_display)
			
			item_display.purchased.connect(func() -> void:
				item_purchased.emit(item)
				item_display.update()
			)
# ==============================================================================
@onready var _items_container: HFlowContainer = %HFlowContainer
# ==============================================================================
signal item_purchased(item: TokenShopItemBase)
# ==============================================================================
