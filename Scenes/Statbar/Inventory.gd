extends MarginContainer
class_name Inventory

# ==============================================================================
static var _instance: Inventory

static var items: Array[Item] = Eternal.create([] as Array[Item])
#static var item_paths: PackedStringArray = Eternal.create(PackedStringArray()) :
	#set(value):
		#item_paths = value
		#
		#for item in items:
			#EffectManager.unregister_object(item)
		#
		#items.clear()
		#
		#for path in value:
			#add_item(Item.from_path(path))
	#get:
		#return items.map(func(item: Item): return item.get_path())
# ==============================================================================
@onready var _item_grid: GridContainer = %ItemGrid
# ==============================================================================

func _enter_tree() -> void:
	_instance = self


func _exit_tree() -> void:
	if _instance == self:
		_instance = null


func _ready() -> void:
	for item in items:
		_add_item_node(item)


func _add_item_node(item: Item) -> void:
	item.in_inventory = true
	
	var node := item.get_node()
	_item_grid.add_child(node)


## Adds an item to the player's inventory and calls [method Item.gain] (in that order).
static func gain_item(item: Item) -> void:
	add_item(item)
	
	item.gain()
	Effects.item_gain(item)


## Adds an item to the player's inventory.
## [br][br][b]Note:[/b] This method only adds the item to the inventory. This calls the item's
## [method Item.inventory_add] initialization method, but does [b]not[/b] call [method Item.gain],
## so effects that occur when the player gains the item do not occur. To gain an item,
## see [method gain_item].
static func add_item(item: Item) -> void:
	EffectManager.register_object(item)
	
	items.append(item)
	if _instance:
		_instance._add_item_node(item)
	
	item.inventory_add()
	Effects.inventory_add_item(item)


## Transforms [code]old_item[/code] into [code]new_item[/code]. The new item will
## be in the same position as the old item.
## [br][br][b]Note:[/b] Replacing an item not in the player's inventory results
## in undefined behaviour.
static func transform_item(old_item: Item, new_item: Item) -> void:
	var old_index := items.find(old_item)
	items[old_index] = new_item
	
	if _instance:
		_instance._item_grid.remove_child(old_item.node)
		_instance._item_grid.add_child(new_item.get_node())
		_instance._item_grid.move_child(new_item.get_node(), old_index)
	
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
static func remove_item(item: Item) -> void:
	item.node.queue_free()
	items.erase(item)
	
	item.lose()
	Effects.item_lose(item)
	
	EffectManager.unregister_object(item)


## Randomly distributes [code]mana[/code] mana across all items in the player's inventory.
static func gain_mana(mana: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = RNG.randi()
	
	var mana_items: Array[Item] = []
	mana_items.assign(items.filter(func(item: Item) -> bool: return item.data.mana))
	
	for i in mana:
		mana_items[rng.randi() % mana_items.size()].gain_mana(1)
