extends RefCounted
#class_name EternalFile

# ==============================================================================
var _file_data := {}
var _resource_ref_counters := {}
var _resource_rids := {}
# ==============================================================================
signal value_changed(section: String, key: String, value: Variant)
# ==============================================================================

func clear() -> void:
	_file_data.clear()


func encode_to_text() -> String:
	var text := ""
	
	for section in get_sections(true):
		text += "[" + section + "]\n\n"
		
		for key in get_section_keys(section):
			var value = get_value(section, key)
			if value is Resource:
				text += key + "=$" + UserClassDB.script_get_identifier(value.get_script()) + "#" + str(value.get_instance_id()) + "\n"
			elif value is Array:
				text += key + "="
				if value.is_typed():
					text += "Array[%s]([" % UserClassDB.script_get_identifier(value.get_typed_script())
				else:
					text += "["
				text += ", ".join(value.map(func(a) -> String:
					if a is Resource:
						return "$" + UserClassDB.script_get_identifier(a.get_script()) + "#" + str(a.get_instance_id())
					return Stringifier.stringify(a)
				))
				
				if value.is_typed():
					text += "])"
				else:
					text += "]"
				
				text += "\n"
			else:
				text += key + "=" + Stringifier.stringify(value) + "\n"
		
		text += "\n"
	
	return text


func erase_section(section: String) -> void:
	if not has_section(section):
		push_error("Section %s does not exist." % section)
		return
	
	for key in _file_data[section]:
		if _file_data[section][key] is Resource:
			_resource_ref_counters[_file_data[section][key]] -= 1
	
	_file_data.erase(section)


func erase_section_key(section: String, key: String) -> void:
	if not has_section_key(section, key):
		push_error("Section-key pair %s-%s does not exist." % [section, key])
		return
	
	if _file_data[section][key] is Resource:
		_resource_ref_counters[_file_data[section][key]] -= 1
	
	_file_data[section].erase(key)


func get_section_keys(section: String) -> PackedStringArray:
	if not has_section(section):
		push_error("Section %s does not exist." % section)
		return []
	
	return _file_data[section].keys()


func get_sections(include_internal: bool = false) -> PackedStringArray:
	if include_internal:
		return _file_data.keys()
	return _file_data.keys().filter(func(section: String) -> bool: return not section.begins_with("$"))


func get_value(section: String, key: String, default: Variant = null) -> Variant:
	if not has_section_key(section, key):
		if default == null:
			push_error("Section-key pair %s-%s does not exist." % [section, key])
		return default
	
	var value = _file_data[section][key]
	
	if value is ResourceReference:
		return _construct_resource(value, section, key)
		#if value._rid in _resource_rids:
			#_file_data[section][key] = _resource_rids[value._rid]
			#_resource_ref_counters[_resource_rids[value._rid]] += 1
			#return _resource_rids[value._rid]
		#
		#var resource: Resource = value._resource_script.new()
		#
		#var resource_section := "$" + UserClassDB.script_get_identifier(value._resource_script) + "#" + str(value._rid)
		#assert(has_section(resource_section))
		#
		#for prop in get_section_keys(resource_section):
			#var prop_value = get_value(resource_section, prop)
			#resource.set(prop, prop_value)
		#
		#_file_data[section][key] = resource
		#_resource_rids[value._rid] = resource
		#_resource_ref_counters[resource] = 1
		#
		#return resource
	if value is TypedResourceReferenceArray:
		return Array(value.array.map(func(a: ResourceReference) -> Resource:
			return _construct_resource(a, section, key)
		), TYPE_OBJECT, value.resource_script.get_instance_base_type(), value.resource_script)
	if value is Array and not value.is_typed():
		return value.map(func(a: Variant) -> Variant:
			if a is ResourceReference:
				return _construct_resource(a, section, key)
			return a
		)
		#var new_array := []
		#for i in value.size():
			#var a = value[i]
			#if a is ResourceReference:
				#new_array.append(a._resource_script.new())
				#var resource_section := "$" + UserClassDB.script_get_identifier(a._resource_script) + "#" + str(a._rid)
				#assert(has_section(resource_section))
				#
				#for prop in get_section_keys(resource_section):
					#new_array[i].set(prop, get_value(resource_section, prop))
		#_file_data[section][key] = new_array
		#return new_array
	
	return value


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
	
	#data = data\
		#.replace("\r", "")\
		#.replace("{\n", "{")\
		#.replace("\n}", "}")\
		#.replace("[\n", "[")\
		#.replace("\n]", "]")\
		#.replace(",\n", ",")
	
	var section := ""
	for line in Stringifier.split_ignoring_nested(data, "\n"):
		if line.is_empty():
			continue
		
		if line.match("[*]"):
			section = line.trim_prefix("[").trim_suffix("]")
			if not has_section(section):
				_file_data[section] = {}
			continue
		
		if line.match("*=*"):
			var key := line.get_slice("=", 0)
			var value_string := line.trim_prefix(key + "=")
			if value_string.begins_with("$"):
				set_value(section, key, ResourceReference.from_string(value_string))
				continue
			
			var value
			if value_string.match("[*]") or value_string.match("Array[*]([*])"):
				if value_string.match("[*]"):
					value = []
				else:
					var class_string := value_string.trim_prefix("Array[").get_slice("]", 0)
					if UserClassDB.is_parent_class(class_string, "Resource"):
						value = TypedResourceReferenceArray.new()
						value.resource_script = UserClassDB.class_get_script(class_string)
					else:
						var type_strings := range(TYPE_MAX).map(func(t: int) -> String: return type_string(t))
						if class_string != "Object" and class_string in type_strings:
							value = Array([], type_strings.find(class_string), &"", null)
						else:
							value = Array([], TYPE_OBJECT, StringName(class_string), UserClassDB.class_get_script(class_string))
						#value = Stringifier.parse(value_string.substr(0, value_string.find("]") + 3) + "])")
					
					value_string = value_string.substr(value_string.find("]") + 2).trim_suffix(")")
				
				for a in Stringifier.split_ignoring_nested(value_string.substr(1, value_string.length() - 2), ", "):
					if a.begins_with("$"):
						value.append(ResourceReference.from_string(a))
					else:
						value.append(Stringifier.parse(a))
			else:
				value = Stringifier.parse(value_string)
			
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
	#if value == null:
		#if has_section_key(section, key):
			#erase_section_key(section, key)
			#if get_section_keys(section).is_empty():
				#erase_section(section)
		#
		#value_changed.emit(section, key, null)
		#return
	
	if not has_section(section):
		_file_data[section] = {}
	
	_file_data[section][key] = value
	
	if value is Resource:
		_store_resource_section(value)
	elif value is Array:
		for i in value:
			if i is Resource:
				_store_resource_section(i)
	
	value_changed.emit(section, key, value)


func _construct_resource(ref: ResourceReference, section: String, key: String) -> Resource:
	if ref._rid in _resource_rids:
		_file_data[section][key] = _resource_rids[ref._rid]
		_resource_ref_counters[_resource_rids[ref._rid]] += 1
		return _resource_rids[ref._rid]
	
	var resource := ref.create_base()
	var resource_section := ref.get_section()
	assert(has_section(resource_section))
	
	_file_data[section][key] = resource
	_resource_rids[ref._rid] = resource
	_resource_ref_counters[resource] = 1
	
	for prop in get_section_keys(resource_section):
		var prop_value = get_value(resource_section, prop)
		resource.set(prop, prop_value)
	
	return resource


func _store_resource_section(resource: Resource) -> void:
	var resource_section := "$" + UserClassDB.script_get_identifier(resource.get_script()) + "#" + str(resource.get_instance_id())
	if has_section(resource_section):
		return
	for prop in UserClassDB.class_get_property_list(UserClassDB.script_get_identifier(resource.get_script())):
		if prop.usage & PROPERTY_USAGE_STORAGE:
			set_value(resource_section, prop.name, resource.get(prop.name))


class ResourceReference:
	var _resource_script: Script
	var _rid: int
	
	func _init(resource_script: Script, rid: int) -> void:
		_resource_script = resource_script
		_rid = rid
	
	func get_section() -> String:
		return "$" + UserClassDB.script_get_identifier(_resource_script) + "#" + str(_rid)
	
	func create_base() -> Resource:
		return _resource_script.new()
	
	static func from_string(string: String) -> ResourceReference:
		return ResourceReference.new(UserClassDB.class_get_script(string.substr(1, string.rfind("#") - 1)), string.substr(string.rfind("#") + 1).to_int())


class TypedResourceReferenceArray:
	var array: Array[ResourceReference] = []
	var resource_script: Script
	
	func append(value: ResourceReference) -> void:
		array.append(value)
