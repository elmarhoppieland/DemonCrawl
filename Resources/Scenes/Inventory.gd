extends MarginContainer
class_name Inventory

# ==============================================================================
var _item_displays := {}
# ==============================================================================
@onready var _item_grid: GridContainer = %ItemGrid
# ==============================================================================

func _ready() -> void:
	for i in Quest.get_current().get_instance().get_item_count():
		_add_item_display(Quest.get_current().get_instance().get_item(i))
	
	Quest.get_current().get_instance().inventory_item_added.connect(func(item: Item) -> void:
		_add_item_display(item)
	)
	Quest.get_current().get_instance().inventory_item_removed.connect(func(item: Item) -> void:
		_item_displays[item].queue_free()
	)
	Quest.get_current().get_instance().inventory_item_transformed.connect(func(old_item: Item, new_item: Item) -> void:
		_item_displays[new_item] = _item_displays[old_item]
		_item_displays[old_item].collectible = new_item
		_item_displays.erase(old_item)
	)


func _add_item_display(item: Item) -> void:
	var display := CollectibleDisplay.create(item)
	_item_grid.add_child(display)
	_item_displays[item] = display


## Adds an item to the player's inventory and calls [method Item.gain] (in that order).
func gain_item(item: Item) -> void:
	add_item(item)
	
	item.notify_gained()
	Effects.item_gain(item)


## Adds an item to the player's inventory.
## [br][br][b]Note:[/b] This method only adds the item to the inventory. This calls the item's
## [method Item.inventory_add] initialization method, but does [b]not[/b] call [method Item.gain],
## so effects that occur when the player gains the item do not occur. To gain an item,
## see [method gain_item].
func add_item(item: Item) -> void:
	get_items().append(item)
	item.notify_inventory_added()
	_add_item_display(item)
	
	item.inventory_add()
	Effects.inventory_add_item(item)


## Transforms [code]old_item[/code] into [code]new_item[/code]. The new item will
## be in the same position as the old item.
## [br][br][b]Note:[/b] Replacing an item not in the player's inventory results
## in undefined behaviour.
func transform_item(old_item: Item, new_item: Item) -> void:
	var old_index := get_items().find(old_item)
	get_items()[old_index] = new_item
	
	_item_grid.remove_child(old_item.node)
	_item_grid.add_child(new_item.get_node())
	_item_grid.move_child(new_item.get_node(), old_index)
	
	old_item.node.queue_free()
	
	old_item.lose()
	Effects.item_lose(old_item)
	EffectManager.unregister_object(old_item)
	
	new_item.inventory_add()
	Effects.inventory_add_item(new_item)
	
	EffectManager.register_object(new_item)
	new_item.gain()
	Effects.item_gain(new_item)


## Removes an item from the player's inventory.
func remove_item(item: Item) -> void:
	item.node.queue_free()
	get_items().erase(item)
	
	item.lose()
	Effects.item_lose(item)
	
	EffectManager.unregister_object(item)


## Randomly distributes [code]mana[/code] mana across all items in the player's inventory.
func gain_mana(mana: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = randi()
	
	var mana_items: Array[Item] = []
	mana_items.assign(get_items().filter(func(item: Item) -> bool: return item.can_recieve_mana()))
	
	for i in mana:
		mana_items[rng.randi() % mana_items.size()].gain_mana(1)


func get_items() -> Array[Item]:
	return Quest.get_current().get_instance().get_items()
