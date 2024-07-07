extends RefCounted
class_name EternalFile

# ==============================================================================
var _file_data := {}
# ==============================================================================

func clear() -> void:
	_file_data.clear()


func encode_to_text() -> String:
	var text := ""
	
	for section in get_sections():
		text += "[" + section + "]\n\n"
		
		for key in get_section_keys(section):
			text += key + "=" + Eternity.stringify(get_value(section, key)) + "\n"
		
		text += "\n"
	
	return text


func erase_section(section: String) -> void:
	if not has_section(section):
		push_error("Section %s does not exist." % section)
		return
	
	_file_data.erase(section)


func erase_section_key(section: String, key: String) -> void:
	if not has_section_key(section, key):
		push_error("Section-key pair %s-%s does not exist." % [section, key])
		return
	
	_file_data[section].erase(key)


func get_section_keys(section: String) -> PackedStringArray:
	if not has_section(section):
		push_error("Section %s does not exist." % section)
		return []
	
	return _file_data[section].keys()


func get_sections() -> PackedStringArray:
	return _file_data.keys()


func get_value(section: String, key: String, default: Variant = null) -> Variant:
	if not has_section_key(section, key):
		if default == null:
			push_error("Section-key pair %s-%s does not exist." % [section, key])
		return default
	
	return _file_data[section][key]


func has_section(section: String) -> bool:
	return section in _file_data


func has_section_key(section: String, key: String) -> bool:
	return key in _file_data.get(section, {})


func load(path: String) -> Error:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return FileAccess.get_open_error()
	
	return parse(file.get_as_text())


func load_encrypted(path: String, key: PackedByteArray) -> Error:
	var file := FileAccess.open_encrypted(path, FileAccess.READ, key)
	if not file:
		return FileAccess.get_open_error()
	
	return parse(file.get_as_text())


func load_encrypted_pass(path: String, password: String) -> Error:
	var file := FileAccess.open_encrypted_with_pass(path, FileAccess.READ, password)
	if not file:
		return FileAccess.get_open_error()
	
	return parse(file.get_as_text())


func parse(data: String) -> Error:
	clear()
	
	data = data\
		.replace("\r", "")\
		.replace("{\n", "{")\
		.replace("\n}", "}")\
		.replace("[\n", "[")\
		.replace("\n]", "]")\
		.replace(",\n", ",")
	
	var section := ""
	for line in data.split("\n"):
		if line.is_empty():
			continue
		
		if line.match("[*]"):
			section = line.trim_prefix("[").trim_suffix("]")
			if not has_section(section):
				_file_data[section] = {}
			continue
		
		if line.match("*=*"):
			var key := line.get_slice("=", 0)
			var value = Eternity.parse(line.trim_prefix(key + "="))
			
			set_value(section, key, value)
			continue
		
		push_error("Invalid line: '%s'." % line)
	
	return OK


func save(path: String) -> Error:
	if not DirAccess.dir_exists_absolute(path.get_base_dir()):
		DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		return FileAccess.get_open_error()
	
	file.store_string(encode_to_text())
	return OK


func save_encrypted(path: String, key: PackedByteArray) -> Error:
	var file := FileAccess.open_encrypted(path, FileAccess.WRITE, key)
	if not file:
		return FileAccess.get_open_error()
	
	file.store_string(encode_to_text())
	return OK


func save_encrypted_pass(path: String, password: String) -> Error:
	var file := FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, password)
	if not file:
		return FileAccess.get_open_error()
	
	file.store_string(encode_to_text())
	return OK


func set_value(section: String, key: String, value: Variant) -> void:
	if value == null:
		if has_section_key(section, key):
			erase_section_key(section, key)
			if get_section_keys(section).is_empty():
				erase_section(section)
		
		return
	
	if not has_section(section):
		_file_data[section] = {}
	
	_file_data[section][key] = value
