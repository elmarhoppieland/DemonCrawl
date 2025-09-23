extends Node
class_name ItemPool

# ==============================================================================
var _modifiers: Array[Callable] = []
# ==============================================================================

## Creates a new [ItemPool.ItemFilter]. Use it to generate random items based on certain filters.
func create_filter() -> ItemFilter:
	var quest := get_parent()
	while quest != null and quest is not Quest:
		quest = quest.get_parent()
	return ItemFilter.new(quest.get_inventory(), _modifiers)


## Adds a [param modifier] [Callable] to the pool. The [Callable] should take in
## one [ItemData] argument, and should return the item's weight modifier, or
## [code]1.0[/code] to leave the weight untouched.
func add_modifier(modifier: Callable) -> void:
	if modifier.get_argument_count() == 0:
		Debug.log_error("Cannot add modifier '%s': Expected 1 argument, found 0." % modifier)
		return
	_modifiers.append(modifier)


## Removes a [param modifier] from the pool.
func remove_modifier(modifier: Callable) -> void:
	_modifiers.erase(modifier)


## Filters items in the database.
class ItemFilter:
	var _max_cost := (1 << 63) - 1 # maximum signed 64-bit int (allow any cost)
	var _min_cost := -1 # all items have a cost of at least -1 (allow any cost)
	var _types: Array[Script] = []
	var _type_whitelist := false
	var _ignore_items_in_inventory := true# :
		#get:
			#if Inventory.items.any(func(item: ItemData) -> bool: return item.data == preload("res://assets/items/extra_pocket.tres")):
				#return false
			#return _ignore_items_in_inventory
	var _tags := PackedStringArray()
	#var _rng: RandomNumberGenerator
	
	var _inventory: QuestInventory
	var _modifiers: Array[Callable] = []
	var _custom_filters: Array[Callable] = []
	
	
	func _init(inventory: QuestInventory, modifiers: Array[Callable]) -> void:
		_inventory = inventory
		_modifiers = modifiers
	
	## Only allow items with a cost of [param max_cost] or less.
	func set_max_cost(max_cost: int) -> ItemFilter:
		_max_cost = max_cost
		return self
	
	## Only allow items with a cost of [param min_cost] or higher.
	func set_min_cost(min_cost: int) -> ItemFilter:
		_min_cost = min_cost
		return self
	
	## Only allow items with a cost of exactly [param cost].
	func set_cost(cost: int) -> ItemFilter:
		_max_cost = cost
		_min_cost = cost
		return self
	
	## Only allow items with a type in the given [param types].
	func set_types(types: Array[Script]) -> ItemFilter:
		_type_whitelist = true
		_types = types
		return self
	
	## Allow items with the given type, in addition to types already given.
	func allow_type(type: Script) -> ItemFilter:
		if _type_whitelist:
			if type not in _types:
				_types.append(type)
		else:
			if type in _types:
				_types.erase(type)
		return self
	
	## Do not allow items with the given type.
	func disallow_type(type: Script) -> ItemFilter:
		if _type_whitelist:
			if type in _types:
				_types.erase(type)
		else:
			if type not in _types:
				_types.append(type)
		return self
	
	## Do not allow any item types. Use this in combination with [method allow_type]
	## to only allow a specific type.
	func disallow_all_types() -> ItemFilter:
		_type_whitelist = true
		_types.clear()
		return self
	
	## Allows all item types.
	func allow_all_types() -> ItemFilter:
		_type_whitelist = false
		_types.clear()
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
	
	## Only allow items with the specified [param tag]. If multiple tags are
	## filtered, this filter will match items with any of the specified tags.
	func filter_tag(tag: String) -> ItemFilter:
		if tag not in _tags:
			_tags.append(tag)
		return self
	
	## Adds a custom [param filter]. This filter should take an [ItemData] as an
	## argument and return whether the item should be included.
	func filter_custom(filter: Callable) -> ItemFilter:
		_custom_filters.append(filter)
		return self
	
	## Sets the [RandomNumberGenerator] used for randomizing.
	#func set_rng(rng: RandomNumberGenerator) -> ItemFilter:
		#_rng = rng
		#return self
	
	## Returns a random item that matches this filter.
	func get_random_item() -> ItemData:
		var pool := _get_pool()
		if pool.is_empty():
			Debug.log_error("Could not find any items with filter %s." % self)
			return null
		
		var cumulative_weights := PackedFloat32Array()
		for item in pool:
			if cumulative_weights.is_empty():
				cumulative_weights.append(pool[item])
			else:
				cumulative_weights.append(cumulative_weights[-1] + pool[item])
		
		var rolled := randf() * cumulative_weights[-1]
		var idx := cumulative_weights.bsearch(rolled)
		
		return pool.keys()[idx]
	
	## Returns [param count] random different items that match this filter.
	func get_random_item_set(count: int) -> Array[ItemData]:
		var pool := _get_pool()
		if pool.is_empty():
			Debug.log_error("Could not find any items with filter %s." % self)
			return []
		
		var cumulative_weights := PackedFloat32Array()
		for item in pool:
			if cumulative_weights.is_empty():
				cumulative_weights.append(pool[item])
			else:
				cumulative_weights.append(cumulative_weights[-1] + pool[item])
		
		var indexes := PackedInt32Array()
		var items: Array[ItemData] = []
		items.resize(count)
		for i in count:
			if pool.size() == indexes.size():
				Debug.log_error("Could not find more than %d items with filter %s." % [indexes.size(), self])
				return items
			
			while true:
				var rolled := randf() * cumulative_weights[-1]
				var index := cumulative_weights.bsearch(rolled)
				
				if index in indexes:
					continue
				
				indexes.insert(indexes.bsearch(index), index)
				
				items[i] = pool.keys()[index]
				break
		
		return items
	
	## Returns all items that match this filter.
	func get_items() -> Array[ItemData]:
		var items: Array[ItemData] = []
		items.assign(ItemDB.get_items().filter(matches))
		return items
	
	## Returns [code]true[/code] if no items match this filter.
	func is_empty() -> bool:
		return not ItemDB.get_items().any(matches)
	
	## Returns whether the given [param data] matches this filter.
	func matches(item: ItemData) -> bool:
		if item.cost > _max_cost:
			return false
		if item.cost < _min_cost:
			return false
		if not _matches_type(item):
			return false
		if not item.can_find(_inventory.get_quest(), _ignore_items_in_inventory):
			return false
		if not _tags.is_empty() and Array(_tags).all(func(tag: String) -> bool: return not tag in item.tags):
			return false
		if not _custom_filters.all(func(callable: Callable) -> bool: return callable.call()):
			return false
		
		return true
	
	func _matches_type(item: ItemData) -> bool:
		for type in _types:
			var base := item.item_script as Script
			while base != null and base != type:
				base = base.get_base_script()
			if _type_whitelist != (base != null):
				return false
		
		return true
	
	func _get_pool() -> Dictionary[ItemData, float]:
		_validate_modifiers()
		
		var pool: Dictionary[ItemData, float] = {}
		
		for item in ItemDB.get_items().filter(matches):
			pool[item] = _get_weight(item)
		
		return pool
	
	func _get_weight(item: ItemData) -> float:
		var weight := 1.0
		for callable in _modifiers:
			weight *= callable.call(item)
		return weight
	
	
	func _validate_modifiers() -> void:
		var invalid_count := 0
		for i in _modifiers.size():
			if not _modifiers[i - invalid_count].is_valid():
				_modifiers.remove_at(i - invalid_count)
				invalid_count += 1
	
	func _to_string() -> String:
		return "<ItemDB.ItemFilter(%s)>" % ", ".join(get_property_list()\
			.filter(func(prop: Dictionary) -> bool: return prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and prop.class_name.is_empty())\
			.map(func(prop: Dictionary) -> String: return "%s: %s" % [prop.name.capitalize(), get(prop.name)])
		)
