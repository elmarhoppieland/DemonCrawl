@tool
extends MarginContainer
class_name Inventory

# ==============================================================================
@export var inventory: QuestInventory = null :
	set(value):
		if inventory and inventory.child_order_changed.is_connected(_update):
			inventory.child_order_changed.disconnect(_update)
		
		inventory = value
		
		_update()
		if value and not value.child_order_changed.is_connected(_update):
			value.child_order_changed.connect(_update)
# ==============================================================================
#var _item_displays := {}
# ==============================================================================
@onready var _item_grid: GridContainer = %ItemGrid
# ==============================================================================

#func _ready() -> void:
	#_load_from_current_quest()
	#Quest.current_changed.connect(_load_from_current_quest)


#func _load_from_current_quest() -> void:
	#for child in _item_grid.get_children():
		#child.queue_free()
	#
	#if not Quest.has_current():
		#return
	#
	#for i in Quest.get_current().get_inventory().get_item_count():
		#_add_item_display(Quest.get_current().get_inventory().get_item(i))
	#
	#Quest.get_current().get_inventory().child_order_changed.connect(_update)
	#Quest.get_current().get_inventory().child_entered_tree.connect(func(item: Item) -> void:
		#_add_item_display(item)
	#)
	#Quest.get_current().get_inventory().child_exiting_tree.connect(func(item: Item) -> void:
		#_item_displays[item].queue_free()
	#)
	#Quest.get_current().get_inventory().item_transformed.connect(func(old_item: Item, new_item: Item) -> void:
		#_item_displays[new_item] = _item_displays[old_item]
		#_item_displays[old_item].collectible = new_item
		#_item_displays.erase(old_item)
	#)


#func _add_item_display(item: Item) -> void:
	#var display := CollectibleDisplay.create(item)
	#_item_grid.add_child(display)
	#_item_displays[item] = display


func _update() -> void:
	if not is_node_ready():
		await ready
	
	var item_count := inventory.get_item_count() if inventory else 0
	
	while _item_grid.get_child_count() > item_count:
		var child := _item_grid.get_child(-1)
		_item_grid.remove_child(child)
		child.queue_free()
	
	while _item_grid.get_child_count() < item_count:
		var display := CollectibleDisplay.create()
		_item_grid.add_child(display)
	
	for i in item_count:
		var item := inventory.get_item(i)
		var display := _item_grid.get_child(i) as CollectibleDisplay
		display.collectible = item
