@abstract
class_name ItemDB

# ==============================================================================

## Returns an [ItemData] instance for all items in the database.
static func get_items() -> Array[ItemData]:
	return DemonCrawl.get_full_registry().items
