extends DebugToolButton
class_name DebugToolObjects

# ==============================================================================
const DEBUG_TOOL_OBJECT_DETAILS := preload("res://engine/resources/singletons/debug/debug_tool_object_details.tscn")
# ==============================================================================
var _object_details_cache: DebugToolObjectDetails
# ==============================================================================

func _get_items() -> Array[Control]:
	var items: Array[Control] = []
	
	for script_name in UserClassDB.get_inheriters_from_class(&"CellObject"):
		var script := UserClassDB.class_get_script(script_name)
		if script.is_abstract():
			continue
		
		var object: CellObject = script.new()
		
		var display := TextureNodeDisplay.new()
		display.custom_minimum_size = Cell.CELL_SIZE
		display.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		display.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		display.display_as_child(object)
		
		var tooltip_grabber := TooltipGrabber.new()
		tooltip_grabber.text = object.get_name_id()
		display.add_child(tooltip_grabber)
		
		var frame := Frame.create(display)
		frame.set_meta("object", object)
		frame.interacted.connect(item_selected.emit.bind(frame))
		
		items.append(frame)
	
	return items


func _handle_item_selected(item: Control) -> Control:
	var object_details: DebugToolObjectDetails
	if is_instance_valid(_object_details_cache) and _object_details_cache.is_inside_tree():
		object_details = _object_details_cache
	else:
		object_details = DEBUG_TOOL_OBJECT_DETAILS.instantiate()
	
	_object_details_cache = object_details
	
	object_details.object = item.get_meta("object").get_script().new()
	return object_details


func _handle_search(search: String, items: Array[Control]) -> void:
	for item in items:
		if search.is_empty():
			item.show()
			continue
		
		var object: CellObject = item.get_meta("object")
		item.visible = search.to_lower() in tr(object.get_name_id()).to_lower()
