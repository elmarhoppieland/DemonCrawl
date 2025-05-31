@tool
extends Control
class_name TokenShopCategoryDisplay

# ==============================================================================
@export var category: TokenShopCategoryBase = null :
	set(value):
		category = value
		
		if not is_node_ready():
			await ready
		
		if value == null:
			for child in _items_container.get_children():
				child.queue_free()
			return
		
		var item_display_scene := load("res://Engine/Scenes/TokenShop/TokenShopItemDisplay.tscn") as PackedScene
		
		for item in value.get_items():
			var item_display := item_display_scene.instantiate() as TokenShopItemDisplay
			item_display.item = item
			
			_items_container.add_child(item_display)
			
			item_display.purchased.connect(func() -> void:
				var result := category.try_purchase(item)
				if result:
					item_display.update()
			)
# ==============================================================================
@onready var _items_container: Container = %ItemsContainer
# ==============================================================================
