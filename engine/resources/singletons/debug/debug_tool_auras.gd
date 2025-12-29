extends DebugToolButton
class_name DebugToolAuras

# ==============================================================================
const DEBUG_TOOL_AURA_DETAILS := preload("res://engine/resources/singletons/debug/debug_tool_aura_details.tscn")
# ==============================================================================
var _aura_details_cache: DebugToolAuraDetails
# ==============================================================================

func _get_items() -> Array[Control]:
	var items: Array[Control] = []
	
	for script_name in UserClassDB.get_inheriters_from_class(&"Aura"):
		var script := UserClassDB.class_get_script(script_name)
		if script.is_abstract():
			continue
		
		var aura: Aura = script.new()
		
		var display := TextureRect.new()
		display.texture = get_theme_icon("bg", "Cell")
		display.modulate = aura.get_modulate()
		display.add_child(aura)
		
		var tooltip_grabber := TooltipGrabber.new()
		tooltip_grabber.text = aura.get_name_id()
		display.add_child(tooltip_grabber)
		
		var frame := Frame.create(display)
		frame.set_meta("aura", aura)
		frame.interacted.connect(item_selected.emit.bind(frame))
		
		items.append(frame)
	
	return items


func _handle_item_selected(item: Control) -> Control:
	var aura_details: DebugToolAuraDetails
	if is_instance_valid(_aura_details_cache) and _aura_details_cache.is_inside_tree():
		aura_details = _aura_details_cache
	else:
		aura_details = DEBUG_TOOL_AURA_DETAILS.instantiate()
	
	_aura_details_cache = aura_details
	
	aura_details.aura = item.get_meta("aura").get_script().new()
	return aura_details


func _handle_search(search: String, items: Array[Control]) -> void:
	for item in items:
		if search.is_empty():
			item.show()
			continue
		
		var aura: Aura = item.get_meta("aura")
		item.visible = search.to_lower() in tr(aura.get_name_id()).to_lower()
