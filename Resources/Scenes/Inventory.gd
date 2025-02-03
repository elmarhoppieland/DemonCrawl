extends MarginContainer
class_name Inventory

# ==============================================================================
var _item_displays := {}
# ==============================================================================
@onready var _item_grid: GridContainer = %ItemGrid
# ==============================================================================

func _ready() -> void:
	for i in Quest.get_current().get_inventory().get_item_count():
		_add_item_display(Quest.get_current().get_inventory().get_item(i))
	
	Quest.get_current().get_inventory().item_added.connect(func(item: Item) -> void:
		_add_item_display(item)
	)
	Quest.get_current().get_inventory().item_removed.connect(func(item: Item) -> void:
		_item_displays[item].queue_free()
	)
	Quest.get_current().get_inventory().item_transformed.connect(func(old_item: Item, new_item: Item) -> void:
		_item_displays[new_item] = _item_displays[old_item]
		_item_displays[old_item].collectible = new_item
		_item_displays.erase(old_item)
	)


func _add_item_display(item: Item) -> void:
	var display := CollectibleDisplay.create(item)
	_item_grid.add_child(display)
	_item_displays[item] = display
