extends RefCounted
class_name Eternal

# ==============================================================================

static func create(default: Variant) -> Variant:
	if not OS.is_debug_build():
		return default
	if Engine.is_editor_hint():
		return default
	
	_register_eternal.call_deferred(default, get_stack())
	
	return default


static func _register_eternal(default: Variant, stack: Array[Dictionary]) -> void:
	if stack.is_empty():
		return
	
	var idx := 0
	while stack[idx].function != "create":
		idx += 1
	idx += 1
	
	var source: String = stack[idx].source
	var file := FileAccess.open(source, FileAccess.READ)
	if not file:
		push_error("Could not open source '%s': %s." % [source, FileAccess.get_open_error()])
		return
	
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
	
	var class_string := ""
	for class_data in ProjectSettings.get_global_class_list():
		if class_data.path == source:
			class_string = class_data.class
			break
	
	var subclasses := UserClassDB.class_get_subclasses(class_string)
	var new_class_string := ""
	for i in range(0, stack[idx].line):
		var l := lines[i]
		if not l.match("class *:"):
			continue
		if not l.begins_with("\t"):
			new_class_string = ""
		
		for subclass in subclasses:
			var base_type := UserClassDB.class_get_script(subclass).get_instance_base_type()
			var subclass_name := subclass.get_slice(":", subclass.get_slice_count(":") - 1)
			if l.begins_with("class %s:" % subclass_name) or l.begins_with("class %s extends %s:" % [subclass_name, base_type]):
				new_class_string = subclass
				break
	
	if not new_class_string.is_empty():
		class_string = new_class_string
	
	if not line.lstrip("\t").begins_with("static var"):
		push_error("Eternal '%s' (on class '%s') was not assigned to a static variable. Eternals must be assigned to a static variable." % [prop_name, class_string])
		return
	
	Eternity._defaults_cfg.set_value(class_string, prop_name, default)
