extends DebugToolButton
class_name DebugToolItems

# ==============================================================================
const DEBUG_TOOL_ITEM_DETAILS := preload("res://engine/resources/singletons/debug/debug_tool_item_details.tscn")
# ==============================================================================
var _item_details_cache: DebugToolItemDetails
# ==============================================================================

func _get_items() -> Array[Control]:
	var items: Array[Control] = []
	var registry := DemonCrawl.get_full_registry()
	
	for item in registry.items:
		var frame := Frame.create(CollectibleDisplay.create(item.create(), true))
		frame.set_meta("item", item)
		frame.interacted.connect(item_selected.emit.bind(frame))
		items.append(frame)
	
	return items


func _handle_item_selected(item: Control) -> Control:
	var item_details: DebugToolItemDetails
	if is_instance_valid(_item_details_cache) and _item_details_cache.is_inside_tree():
		item_details = _item_details_cache
	else:
		item_details = DEBUG_TOOL_ITEM_DETAILS.instantiate()
	
	_item_details_cache = item_details
	
	item_details.item = item.get_meta("item")
	return item_details


func _handle_search(search: String, items: Array[Control]) -> void:
	for frame: Frame in items:
		if search.is_empty():
			frame.show()
			continue
		
		var item := (frame.get_content() as CollectibleDisplay).collectible as Item
		var item_name := tr(item.get_item_name())
		var item_description := tr(item.get_description())
		frame.visible = search.to_lower() in item_name.to_lower() or search.to_lower() in item_description.to_lower()
