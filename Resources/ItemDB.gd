extends StaticClass
class_name ItemDB

# ==============================================================================
const BASE_DIR := "res://Assets/items/"
# ==============================================================================

## Returns an [ItemData] [Resource] for all items in the database.
static func get_items_data() -> Array[ItemData]:
	var items: Array[ItemData] = []
	for file in DirAccess.get_files_at(BASE_DIR):
		file = file.trim_suffix(".remap") # for exported builds
		if file.get_extension() != "tres":
			continue
		items.append(ResourceLoader.load(BASE_DIR.path_join(file)))
	return items


## Creates a new [ItemDB.ItemFilter]. Use it to generate random items based on certain filters.
static func create_filter() -> ItemFilter:
	return ItemFilter.new()


## Filters items in the database.
class ItemFilter:
	var _max_cost := (1 << 63) - 1 # maximum signed 64-bit int (allow any cost)
	var _min_cost := -1 # all items have a cost of at least -1 (allow any cost)
	var _types: int = (1 << Item.Type.MAX) - 1
	var _ignore_items_in_inventory := true :
		get:
			if Inventory.items.any(func(item: Item): return item.data == preload("res://Assets/items/Extra Pocket.tres")):
				return false
			return _ignore_items_in_inventory
	var _rng: RandomNumberGenerator
	
	
	## Only allow items with a cost of [code]max_cost[/code] or less.
	func set_max_cost(max_cost: int) -> ItemFilter:
		_max_cost = max_cost
		return self
	
	## Only allow items with a cost of [code]min_cost[/code] or higher.
	func set_min_cost(min_cost: int) -> ItemFilter:
		_min_cost = min_cost
		return self
	
	## Only allow items with a cost of exactly [code]cost[/code].
	func set_cost(cost: int) -> ItemFilter:
		_max_cost = cost
		_min_cost = cost
		return self
	
	## Only allow items with a type in the given bitmask. Use [code]1 << type[/code]
	## to get the bit for a specific type.
	## [br][br]See also [method allow_type].
	func set_types(types: int) -> ItemFilter:
		_types = types
		return self
	
	## Allow items with the given type, in addition to types already given.
	func allow_type(type: Item.Type) -> ItemFilter:
		_types |= (1 << type)
		return self
	
	## Do not allow items with the given type.
	func disallow_type(type: Item.Type) -> ItemFilter:
		_types &= ~(1 << type)
		return self
	
	## Do not allow any item types. Use this in combination with [method allow_type]
	## to only allow a specific type.
	func disallow_all_types() -> ItemFilter:
		_types = 0
		return self
	
	## Specify whether items in the player's inventory should be excluded. If
	## no argument is given, sets it to ignore the player's items. This is the
	## inverse of [method set_allow_items_in_inventory].
	## [br][br][b]Note:[/b] The default behaviour has this set to [code]true[/code].
	## This is the same as when [method set_ignore_items_in_inventory] is called
	## without any arguments.
	func set_ignore_items_in_inventory(ignore_items_in_inventory: bool = true) -> ItemFilter:
		_ignore_items_in_inventory = ignore_items_in_inventory
		return self
	
	## Specify whether items in the player's inventory should be allowed. If
	## no argument is given, sets it to allow the player's items. This is the
	## inverse of [method set_ignore_items_in_inventory].
	func set_allow_items_in_inventory(allow_items_in_inventory: bool = true) -> ItemFilter:
		_ignore_items_in_inventory = not allow_items_in_inventory
		return self
	
	## Sets the [RandomNumberGenerator] used for randomizing.
	func set_rng(rng: RandomNumberGenerator) -> ItemFilter:
		_rng = rng
		return self
	
	## Returns a random item that matches this filter.
	func get_random_item() -> Item:
		var options := get_items_data()
		if options.is_empty():
			Debug.log_error("Could not find any items with filter %s." % self)
			return null
		
		return options[RNG.randi(_rng) % options.size()].get_item_script().new()
	
	## Returns [code]count[/code] random different items that match this filter.
	func get_random_item_set(count: int) -> Array[Item]:
		var options := get_items_data()
		
		if options.is_empty():
			Debug.log_error("Could not find any items with filter %s." % self)
			return []
		
		var indexes := PackedInt32Array()
		var items: Array[Item] = []
		for i in count:
			if options.size() == indexes.size():
				Debug.log_error("Could not find more than %d items with filter %s." % [indexes.size(), self])
				return items
			
			var index := RNG.randi(_rng) % (options.size() - indexes.size())
			
			for j in indexes:
				if j <= index:
					index += 1
			
			indexes.append(index)
			indexes.sort()
			
			items.append(options[index].get_item_script().new())
		
		return items
	
	## Returns all items that match this filter.
	func get_items_data() -> Array[ItemData]:
		return Array(ItemDB.get_items_data().filter(matches), TYPE_OBJECT, &"Resource", ItemData)
	
	## Returns [code]true[/code] if no items match this filter.
	func is_empty() -> bool:
		return not ItemDB.get_items_data().any(matches)
	
	## Returns whether the given [code]data[/code] matches this filter.
	func matches(data: ItemData) -> bool:
		if data.cost > _max_cost:
			return false
		if data.cost < _min_cost:
			return false
		if not (1 << data.type) & _types:
			return false
		if _ignore_items_in_inventory and data.type != Item.Type.CONSUMABLE and Inventory.items.any(func(item: Item): return item.data == data):
			return false
		
		return true
	
	func _to_string() -> String:
		return "<ItemDB.ItemFilter(%s)>" % ", ".join(get_property_list()\
			.filter(func(prop: Dictionary): return prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and prop.class_name.is_empty())\
			.map(func(prop: Dictionary): return "%s: %s" % [prop.name.capitalize(), get(prop.name)])
		)
