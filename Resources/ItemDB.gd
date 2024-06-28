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


## Returns a random item with a maximum cost of [code]max_cost[/code].
static func get_random_item(max_cost: int, min_cost: int = -1, types: int = (1 << Item.Type.MAX) - 1, rng: RandomNumberGenerator = null) -> Item:
	var options := get_filtered_items(max_cost, min_cost, types)
	
	if options.is_empty():
		return null
	
	return options[RNG.randi(rng) % options.size()].get_item_script().new()


## Returns [code]count[/code] random different items with a maximum cost of [code]max_cost[/code].
static func get_random_item_set(max_cost: int, count: int, min_cost: int = -1, types: int = (1 << Item.Type.MAX) - 1, rng: RandomNumberGenerator = null) -> Array[Item]:
	if max_cost < min_cost:
		return []
	
	var options := get_filtered_items(max_cost, min_cost)
	
	var indexes := PackedInt32Array()
	var items: Array[Item] = []
	for i in count:
		if options.size() == indexes.size():
			Debug.log_error("Could not find more than %d items with a max_cost of %d, a min_cost of %d with types %d." % [items.size(), max_cost, min_cost, types])
			return items
		
		var index := RNG.randi(rng) % (options.size() - indexes.size())
		
		for j in indexes:
			if j <= index:
				index += 1
		
		indexes.append(index)
		indexes.sort()
		
		items.append(options[index].get_item_script().new())
	
	return items


## Returns all items with a maximum cost of [code]max_cost[/code] (inclusive).
## If a [code]min_cost[/code] is specified, the returned items will also have a
## minimum cost of [code]min_cost[/code] (inclusive).
static func get_filtered_items(max_cost: int, min_cost: int = -1, types: int = (1 << Item.Type.MAX) - 1) -> Array[ItemData]:
	return get_items_data().filter(func(a: ItemData):
		return a.cost <= max_cost and (min_cost < 0 or a.cost >= min_cost) and (1 << a.type) & types
	)
