extends StaticClass
class_name ItemDB

# ==============================================================================
const BASE_DIR := "res://Assets/items/"

const ItemFilter := ItemPool.ItemFilter
# ==============================================================================
static var _items_cache: Array[ItemData] = []
# ==============================================================================

## Returns an [ItemData] [Resource] for all items in the database.
static func get_items() -> Array[ItemData]:
	if not _items_cache.is_empty():
		return _items_cache
	
	for file in DirAccess.get_files_at(BASE_DIR):
		if ResourceLoader.exists(BASE_DIR.path_join(file)):
			var resource := load(BASE_DIR.path_join(file))
			if resource is ItemData:
				_items_cache.append(resource)
	return _items_cache


## Creates a new [ItemDB.ItemFilter]. Use it to generate random items based on certain filters.
static func create_filter(inventory: QuestInventory) -> ItemFilter:
	return ItemFilter.new(inventory, [])


static func clear_cache() -> void:
	_items_cache.clear()
