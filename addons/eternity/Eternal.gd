extends StaticClass
class_name Eternal

# ==============================================================================

static func create(default: Variant, path_name: String = "") -> Variant:
	if Engine.is_editor_hint():
		return default
	
	if not OS.is_debug_build():
		Eternity._queue_named_path_load(path_name)
		return default
	
	_register_eternal(default, get_stack(), path_name)
	
	Eternity._queue_named_path_load(path_name)
	return default


static func _register_eternal(default: Variant, stack: Array[Dictionary], path_name: String = "") -> void:
	if stack.is_empty():
		return
	
	var script := _get_calling_script_class(stack, "create")
	var prop_name := _get_calling_var_key(stack, "create")
	
	if path_name.is_empty():
		Eternity.get_defaults_cfg().set_eternal(script, prop_name, default)
	else:
		Eternity.get_defaults_cfg().set_eternal(script, path_name + "::" + prop_name, default)


static func _get_calling_script_class(stack: Array[Dictionary], before_function: String) -> String:
	assert(not stack.is_empty(), "_get_class_script() can only be used in a debug build.")
	
	var idx := 0
	while stack[idx].function != before_function:
		idx += 1
	idx += 1
	
	var source: String = stack[idx].source
	return UserClassDB.class_get_name(source)


static func _get_calling_var_key(stack: Array[Dictionary], before_function: String) -> String:
	assert(not stack.is_empty(), "_get_calling_var_key() can only be used in a debug build.")
	
	var idx := 0
	while stack[idx].function != before_function:
		idx += 1
	idx += 1
	
	var source: String = stack[idx].source
	var file := FileAccess.open(source, FileAccess.READ)
	if not file:
		push_error("Could not open source '%s': %s." % [source, FileAccess.get_open_error()])
		return ""
	
	var text := file.get_as_text(true).replace("\\\n", " ")
	while "  " in text:
		text = text.replace("  ", " ")
	var lines := text.split("\n")
	
	var line_index: int = stack[idx].line - 1
	var line := lines[line_index]
	
	var prop_name := line.trim_prefix(line.get_slice("var", 0) + "var").get_slice("=", 0).strip_edges()
	if ":" in prop_name:
		prop_name = prop_name.get_slice(":", 0)
	prop_name = prop_name.replace(" ", "").replace("\t", "")
	
	if not line.lstrip("\t").begins_with("static var"):
		push_error("Eternal '%s' (on class '%s') was not assigned to a static variable. Eternals must be assigned to a static variable." % [prop_name, _get_calling_script_class(stack, before_function)])
		return ""
	
	return prop_name
