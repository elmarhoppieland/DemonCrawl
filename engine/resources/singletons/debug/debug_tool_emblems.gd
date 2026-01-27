extends DebugToolButton
class_name DebugToolEmblems

# ==============================================================================
const DEBUG_TOOL_EMBLEM_DETAILS := preload("res://engine/resources/singletons/debug/debug_tool_emblem_details.tscn")
# ==============================================================================
var _emblem_details_cache: DebugToolEmblemDetails
# ==============================================================================

func _get_items() -> Array[Control]:
	var items: Array[Control] = []
	var registry := DemonCrawl.get_full_registry()
	
	for emblem in registry.emblems:
		var display := TextureRect.new()
		display.texture = emblem.icon
		
		var tooltip_grabber := TooltipGrabber.new()
		tooltip_grabber.text = emblem.name
		tooltip_grabber.subtext = emblem.get_description()
		tooltip_grabber.text_color = EmblemObject.TITLE_COLOR
		tooltip_grabber.max_line_length = EmblemObject.MAX_LINE_LENGTH
		display.add_child(tooltip_grabber)
		
		var frame := Frame.create(display)
		frame.set_meta("emblem", emblem)
		frame.interacted.connect(item_selected.emit.bind(frame))
		items.append(frame)
	
	return items


func _handle_item_selected(item: Control) -> Control:
	var emblem_details: DebugToolEmblemDetails
	if is_instance_valid(_emblem_details_cache) and _emblem_details_cache.is_inside_tree():
		emblem_details = _emblem_details_cache
	else:
		emblem_details = DEBUG_TOOL_EMBLEM_DETAILS.instantiate()
	
	_emblem_details_cache = emblem_details
	
	emblem_details.emblem = item.get_meta("emblem")
	return emblem_details


func _handle_search(search: String, items: Array[Control]) -> void:
	for item in items:
		if search.is_empty():
			item.show()
			continue
		
		var emblem: EmblemData = item.get_meta("emblem")
		var emblem_name := tr(emblem.name)
		var emblem_description := emblem.get_description()
		item.visible = search.to_lower() in emblem_name.to_lower() or search.to_lower() in emblem_description.to_lower()
