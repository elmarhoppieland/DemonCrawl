extends DebugToolButton
class_name DebugToolGlints

# ==============================================================================
const DEBUG_TOOL_EMBLEM_DETAILS := preload("res://engine/resources/singletons/debug/debug_tool_glint_details.tscn")
# ==============================================================================
var _glint_details_cache: DebugToolGlintDetails
# ==============================================================================

func _get_items() -> Array[Control]:
	var items: Array[Control] = []
	var registry := DemonCrawl.get_full_registry()
	
	for glint in registry.glints:
		var display := TextureRect.new()
		display.texture = glint.icon
		
		var tooltip_grabber := TooltipGrabber.new()
		tooltip_grabber.text = glint.name
		tooltip_grabber.subtext = glint.get_description()
		tooltip_grabber.text_color = GlintObject.TITLE_COLOR
		tooltip_grabber.max_line_length = GlintObject.MAX_LINE_LENGTH
		display.add_child(tooltip_grabber)
		
		var frame := Frame.create(display)
		frame.set_meta("glint", glint)
		frame.interacted.connect(item_selected.emit.bind(frame))
		items.append(frame)
	
	return items


func _handle_item_selected(item: Control) -> Control:
	var glint_details: DebugToolGlintDetails
	if is_instance_valid(_glint_details_cache) and _glint_details_cache.is_inside_tree():
		glint_details = _glint_details_cache
	else:
		glint_details = DEBUG_TOOL_EMBLEM_DETAILS.instantiate()
	
	_glint_details_cache = glint_details
	
	glint_details.glint = item.get_meta("glint")
	return glint_details


func _handle_search(search: String, items: Array[Control]) -> void:
	for item in items:
		if search.is_empty():
			item.show()
			continue
		
		var glint: GlintData = item.get_meta("glint")
		var glint_name := tr(glint.name)
		var glint_description := glint.get_description()
		item.visible = search.to_lower() in glint_name.to_lower() or search.to_lower() in glint_description.to_lower()
