extends RefCounted
class_name EternalFile

## Helper class to write [Eternal]s to disk.

# ==============================================================================
var processing_owner_stack: Array[Object] = []
# ==============================================================================
var _data := {}
var _resources := {}

var _rng := RandomNumberGenerator.new()
# ==============================================================================
signal value_changed(section: String, key: String, value: Variant)
signal loaded(path: String)
signal saved(path: String)

signal _resource_saved(id: int)
# ==============================================================================

func clear() -> void:
	_data.clear()
	_resources.clear()


## Loads the file at the given [code]path[/code].
func load(path: String, additive: bool = false) -> void:
	if not FileAccess.file_exists(path):
		if not additive:
			_data.clear()
			_resources.clear()
		
		loaded.emit(path)
		return
	
	var file := FileAccess.open(path, FileAccess.READ)
	_parse_ini(file, additive)
	
	loaded.emit(path)


## Loads all [Resource] ids from the file at the given [code]path[/code].
## This method expects data to already be loaded, and will replace existing
## [Resource] ids with the file's ids.
func load_existing_resources(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	
	var file := FileAccess.open(path, FileAccess.READ)
	
	var sub_resource_positions := {}
	
	processing_owner_stack.clear()
	
	var current_section := ""
	while not file.eof_reached():
		var line := _read_line(file)
		var position := file.get_position()
		
		if line.begins_with("[") and line.ends_with("]"):
			processing_owner_stack.pop_back()
			
			current_section = line.substr(1, line.length() - 2).strip_edges()
			if current_section.begins_with("ext_resource "):
				current_section = ""
				continue
			
			if current_section.begins_with("sub_resource "):
				var id := current_section.get_slice("id=\"", 1).get_slice("\"", 0).hex_to_int()
				sub_resource_positions[id] = position
				continue
			
			processing_owner_stack.append(UserClassDB.class_get_script(line.trim_prefix("[").trim_suffix("]")))
			continue
		
		if "#" in line:
			line = Stringifier.split_ignoring_nested(line, "#")[0].strip_edges()
		if line.is_empty():
			continue
		
		if current_section.is_empty():
			var key := line.get_slice("=", 0).strip_edges()
			var value := line.trim_prefix(key).strip_edges().trim_prefix("=").strip_edges()
			push_warning("Key-value pair '%s'-'%s' found outside of a section in file '%s'. Continuing..." % [key, value])
			continue
		
		var key := line.get_slice("=", 0).strip_edges()
		var value := line.trim_prefix(key).strip_edges().trim_prefix("=").strip_edges()
		assert("=" in line, "Invalid line '%s' in file '%s'." % [line, path])
		
		if not value.match("Resource(*)"):
			continue
		
		var id := value.get_slice("\"", 1).hex_to_int()
		var resource = get_eternal(current_section, key)
		if resource not in _resources.values():
			continue
		
		_resources.erase(_resources.find_key(resource))
		_resources[id] = resource
		
		if not resource.resource_path.is_empty():
			continue
		
		file.seek(sub_resource_positions[id])
		
		_reassign_resource_ids_in_subresource(resource, file, sub_resource_positions)
		
		file.seek(position)
	
	processing_owner_stack.pop_back()
	assert(processing_owner_stack.is_empty(), "Processing stack did not get cleared.")


func _reassign_resource_ids_in_subresource(subresource: Resource, file: FileAccess, sub_resource_positions: Dictionary) -> void:
	while true:
		var line := file.get_line()
		var position := file.get_position()
		if "#" in line:
			line = Stringifier.split_ignoring_nested(line, "#")[0].strip_edges()
		if line.is_empty():
			continue
		if line.match("[*]"):
			return
		
		var key := line.get_slice("=", 0).strip_edges()
		var value := line.trim_prefix(key).strip_edges().trim_prefix("=").strip_edges()
		assert("=" in line, "Invalid line '%s' in file '%s'." % [line, file.get_path()])
		
		if not value.match("Resource(*)"):
			continue
		
		var id := value.get_slice("\"", 1).hex_to_int()
		var resource = subresource.get(key)
		if resource not in _resources.values():
			continue
		
		_resources.erase(_resources.find_key(resource))
		_resources[id] = resource
		
		file.seek(sub_resource_positions[id])
		
		_reassign_resource_ids_in_subresource(resource, file, sub_resource_positions)
		
		file.seek(position)


## Saves the loaded data to [code]path[/code].
func save(path: String, safe_mode: bool = false) -> void:
	var safe_text := ""
	if safe_mode:
		safe_text = encode_to_text()
	
	if not DirAccess.dir_exists_absolute(path.get_base_dir()):
		DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("Could not open file '%s': %s" % [path, error_string(FileAccess.get_open_error())])
		return
	
	if safe_mode:
		file.store_string(safe_text)
	else:
		encode_to_file(file)
	
	file.close()
	
	saved.emit(path)


## Returns a [PackedStringArray] of all [Script]s that have any [Eternal]s.
func get_scripts() -> PackedStringArray:
	var scripts := PackedStringArray()
	for key in _data:
		if _data[key].is_empty():
			continue
		if UserClassDB.class_exists(key):
			scripts.append(key)
	scripts.sort()
	return scripts


## Returns all [Eternal]s saved under the given [code]script[/code].
func get_eternals(script: String) -> PackedStringArray:
	if script in _data:
		return PackedStringArray(_data[script].keys())
	return PackedStringArray()


## Returns the saved value of the [Eternal] in the given [code]script[/code],
## with the given [code]key[/code]. If it is not available, returns [code]default[/code],
## or [code]null[/code] if the parameter is omitted.
func get_eternal(script: String, key: String, default: Variant = null) -> Variant:
	if script not in _data or key not in _data[script]:
		return default
	
	return _data[script][key]


## Sets the value of the [Eternal] in the given [code]script[/code] with the given
## [code]key[/code] to [code]value[/code].
func set_eternal(script: String, key: String, value: Variant) -> void:
	if script not in _data:
		_data[script] = {}
	
	_data[script][key] = _store_resource(value)
	value_changed.emit(script, key, value)


func has_eternal(script: String, key: String) -> bool:
	return script in _data and key in _data[script]


func _store_resource(value: Variant) -> Variant:
	var resources: Array[Resource] = []
	_prepare_variant(value, resources)
	for resource in resources:
		_resource_get_uid(resource)
	
	return value


func _prepare_resource_list() -> Array[Resource]:
	var resources: Array[Resource] = []
	resources.assign(_resources.values())
	var i := 0
	while i < resources.size():
		var resource := resources[i]
		if not resource.resource_path.is_empty() and not "::" in resource.resource_path:
			_resource_get_uid(resource)
			i += 1
			continue
		
		for property in resource.get_property_list():
			if resource.has_method("_validate_property"):
				resource._validate_property(property) # this property should be validated but this isn't the case by default
			
			if property.name == "script":
				continue
			if resource.has_method("_export_" + property.name):
				continue
			if property.usage & PROPERTY_USAGE_STORAGE:
				var value = resource.get(property.name)
				_prepare_variant(value, resources)
		
		_resource_get_uid(resource)
		i += 1
	
	return resources


func _prepare_variant(variant: Variant, resources: Array[Resource]) -> void:
	if variant is Object and _is_object_packable(variant):
		processing_owner_stack.append(variant)
		_prepare_variant(variant._export_packed(), resources)
		processing_owner_stack.pop_back()
	elif variant is Resource and variant not in resources:
		resources.append(variant)
	elif variant is Array:
		_prepare_array(variant, resources)
	elif variant is Dictionary:
		_prepare_dictionary(variant, resources)


func _prepare_array(array: Array, resources: Array[Resource]) -> void:
	if _is_packable(array):
		for v in array:
			if v != null:
				_prepare_variant(v._export_packed(), resources)
		return
	
	for v in array:
		_prepare_variant(v, resources)


func _prepare_dictionary(dict: Dictionary, resources: Array[Resource]) -> void:
	for key in dict:
		_prepare_variant(key, resources)
		_prepare_variant(dict[key], resources)


func _is_object_packable(object: Object) -> bool:
	if object.has_method("_export_packed_enabled") and not object._export_packed_enabled():
		return false
	return object.has_method("_export_packed")


func _is_packable(value: Variant) -> bool:
	if not value is Array or not value.is_typed():
		return false
	
	var script := value.get_typed_script() as Script
	if not script:
		return false
	
	for method in script.get_script_method_list():
		if method.flags & METHOD_FLAG_STATIC:
			continue
		if method.name == "_export_packed":
			return true
	return false


func _parse_ini(file: FileAccess, additive: bool = false) -> void:
	if not additive:
		_data.clear()
		_resources.clear()
	
	processing_owner_stack.clear()
	
	var current_section := ""
	while not file.eof_reached():
		var line := _read_line(file)
		
		if line.begins_with("[") and line.ends_with("]"):
			current_section = line.substr(1, line.length() - 2).strip_edges()
			if current_section.begins_with("ext_resource "):
				var id := current_section.get_slice("id=\"", 1).get_slice("\"", 0).hex_to_int()
				assert(id not in _resources, "Duplicate ID found in the file at '%s'." % file.get_path())
				
				var path := current_section.get_slice("path=\"", 1).get_slice("\"", 0)
				if ResourceLoader.exists(path):
					var resource := load(path)
					if resource not in _resources.values():
						_resources[id] = resource
					
					processing_owner_stack.pop_back()
					processing_owner_stack.append(resource)
				else:
					var resource := MissingExtResource.new()
					resource.path = path
					_resources[id] = resource
					
					processing_owner_stack.pop_back()
					processing_owner_stack.append(resource)
				
				current_section = ""
				continue
			
			if current_section.begins_with("sub_resource "):
				var id := current_section.get_slice("id=\"", 1).get_slice("\"", 0).hex_to_int()
				assert(id not in _resources, "Duplicate ID found in the file at '%s'." % file.get_path())
				if current_section.match("* script=\"*\"*"):
					var instance := UserClassDB.instantiate(current_section.get_slice("script=\"", 1).get_slice("\"", 0))
					assert(instance is Resource, "A sub_resource script must use a Resource-extending Script, but %s was found." % instance.get_class())
					_resources[id] = instance
					_resource_saved.emit(id)
					
					processing_owner_stack.pop_back()
					processing_owner_stack.append(instance)
				elif current_section.match("* class=\"*\"*"):
					var instance: Object = ClassDB.instantiate(current_section.get_slice("class=\"", 1).get_slice("\"", 0))
					assert(instance is Resource, "A sub_resource script must use a Resource-extending Script, but %s was found." % instance.get_class())
					_resources[id] = instance
					_resource_saved.emit(id)
					
					processing_owner_stack.pop_back()
					processing_owner_stack.append(instance)
				
				current_section = ""
				continue
			
			if current_section not in _data:
				_data[current_section] = {}
			processing_owner_stack.pop_back()
			processing_owner_stack.append(UserClassDB.class_get_script(line.trim_prefix("[").trim_suffix("]")))
			continue
		
		if current_section.is_empty():
			_parse_line(line, processing_owner_stack[-1], file.get_path())
		else:
			_parse_line(line, _data[current_section], file.get_path())
	
	processing_owner_stack.pop_back()
	assert(processing_owner_stack.is_empty(), "Processing stack did not get cleared.")


func _read_line(file: FileAccess) -> String:
	var line := ""
	while not file.eof_reached():
		line = file.get_line().strip_edges()
		if "#" in line:
			line = line.substr(0, line.find("#")).strip_edges()
		if line.is_empty():
			continue
		
		if line.begins_with("[") and line.ends_with("]"):
			return line
		
		assert("=" in line, "Invalid line '%s' in file '%s'." % [line, file.get_path()])
		var value := line.trim_prefix(line.get_slice("=", 0)).strip_edges().trim_prefix("=").strip_edges()
		while not _validate_value_string(value):
			var new_line := file.get_line().strip_edges()
			line += "\n" + new_line
			value += new_line
		
		return line
	
	return line


func _parse_line(line: String, owner: Variant, file_path: String) -> void:
	if "#" in line:
		line = line.substr(0, line.find("#")).strip_edges()
	if line.is_empty():
		return
	
	var key := line.get_slice("=", 0).strip_edges()
	var value := line.trim_prefix(key).strip_edges().trim_prefix("=").strip_edges()
	assert("=" in line, "Invalid line '%s' in file '%s'." % [line, file_path])
	
	_set_variant(owner, key, await await_resource(_parse_value(value)))


func _set_variant(variant: Variant, key: Variant, value: Variant) -> void:
	match typeof(variant):
		TYPE_DICTIONARY:
			variant[key] = value
		TYPE_OBJECT:
			if key is String or key is StringName:
				variant.set(key, value)


func await_resource(resource: Variant) -> Variant:
	if not resource is PendingResourceBase:
		return resource
	
	var owner := processing_owner_stack[-1]
	
	while not resource.is_ready(_resources):
		await _resource_saved
	
	var added_owner := false
	if processing_owner_stack[-1] != owner:
		processing_owner_stack.append(owner)
		added_owner = true
	
	var value = resource.create(_resources)
	
	if added_owner:
		processing_owner_stack.pop_back()
	
	return value


func _validate_value_string(value: String) -> bool:
	value = value.strip_edges()
	
	if value.begins_with("{"):
		return value[-1] == "}"
	if value.begins_with("["):
		return value[-1] == "]"
	if value.begins_with("Array[") or value.begins_with("PackedArray["):
		return Stringifier.get_depth(value, "(", ")") == 0
	return true


func _parse_value(value: String) -> Variant:
	value = value.strip_edges()
	
	if value == "<null>":
		return null
	if value.is_valid_int():
		return value.to_int()
	if value.is_valid_float():
		return value.to_float()
	if value == "true":
		return true
	if value == "false":
		return false
	if value == "null":
		return null
	if value.begins_with("\"") and value.ends_with("\""):
		return value.substr(1, value.length() - 2)
	
	if value.begins_with("Resource(\"") and value.ends_with("\")"):
		var id := value.get_slice("\"", 1).hex_to_int()
		if id in _resources:
			return _resources[id]
		return PendingResource.new(id)
	
	if value.match("[*]"):
		return _parse_array(value)
	
	if value.match("Array[*]([*])"):
		return _parse_typed_array(value)
	
	if value.match("PackedArray[*](*)"):
		return _parse_packed_array(value)
	
	if value.match("*(*)") and UserClassDB.class_exists(value.get_slice("(", 0)):
		return _parse_constructor(value)
	
	if value.match("{*}"):
		var dict := {}
		var pairs := Stringifier.split_ignoring_nested(value.trim_prefix("{").trim_suffix("}"), ",")
		var is_pending := false
		for pair in pairs:
			pair = pair.strip_edges()
			if pair.is_empty():
				continue
			
			var key_value := Stringifier.split_ignoring_nested(pair, ":")
			var key = _parse_value(key_value[0])
			var parsed_value = _parse_value(key_value[1])
			if key is PendingResourceBase or parsed_value is PendingResourceBase:
				is_pending = true
			elif key is MissingExtResource or parsed_value is MissingExtResource:
				continue
			dict[key] = parsed_value
		if is_pending:
			return PendingResourceDictionary.new(dict)
		return dict
	
	return Stringifier.parse(value)


func _parse_array(value: String) -> Variant:
	var values_string := Stringifier.split_ignoring_nested(value.trim_prefix("[").trim_suffix("]"), ",")
	var values := []
	var is_pending := false
	for s in values_string:
		s = s.strip_edges()
		if s.is_empty():
			continue
		var v = _parse_value(s)
		if v is PendingResourceBase:
			is_pending = true
		elif v is MissingExtResource:
			continue
		values.append(v)
	if is_pending:
		return UntypedPendingResourceArray.new(values)
	return Array(values_string).map(_parse_value)


func _parse_typed_array(value: String) -> Variant:
	var type_name := value.trim_prefix("Array[").get_slice("]", 0)
	if ClassDB.class_exists(type_name):
		return Array(value.split(","), TYPE_OBJECT, type_name, null).map(_parse_value)
	if UserClassDB.class_exists(type_name):
		var script := UserClassDB.class_get_script(type_name)
		var values_string := value.substr(9 + type_name.length()).trim_suffix("])")
		var values := []
		var is_pending := false
		for s in Stringifier.split_ignoring_nested(values_string, ","):
			s = s.strip_edges()
			if s.is_empty():
				continue
			var v = _parse_value(s)
			if v is PendingResourceBase:
				is_pending = true
			elif v is MissingExtResource:
				continue
			values.append(v)
		if is_pending:
			return TypedPendingResourceArray.new(values, Array([], TYPE_OBJECT, script.get_instance_base_type(), script))
		return Array(values, TYPE_OBJECT, script.get_instance_base_type(), script)
	var type := range(TYPE_MAX).map(func(t: int) -> String: return type_string(t)).find(type_name)
	assert(type != -1, "Invalid class name in value '%s'." % value)
	return Array(Array(value.substr(9 + type_name.length()).trim_suffix("])").split(",")).map(_parse_value), type, "", null)


func _parse_packed_array(value: String) -> Variant:
	var script_name := value.trim_prefix("PackedArray[").get_slice("]", 0)
	assert(UserClassDB.class_exists(script_name), "Invalid PackedArray of type '%s': Expected class name.")
	
	var script := UserClassDB.class_get_script(script_name)
	
	var values := []
	var is_pending := false
	for s in Stringifier.split_ignoring_nested(value.trim_prefix("PackedArray[" + script_name + "]" + "(").trim_suffix(")"), ","):
		s = s.strip_edges()
		
		var s_script_name: String
		if not s.begins_with("(") and s.match("*(*)"):
			s_script_name = s.get_slice("(", 0)
		else:
			s_script_name = script_name
		
		var constructor := Constructor.new(s_script_name)
		
		s = s.trim_prefix(s_script_name).trim_prefix("(").trim_suffix(")").strip_edges()
		
		if s == "<null>":
			values.append(null)
			continue
		
		var arg_strings := Stringifier.split_ignoring_nested(s, ",")
		
		var instance := constructor.construct(Array(arg_strings).map(_parse_value))
		if instance is PendingResourceBase:
			is_pending = true
		values.append(instance)
	
	if is_pending:
		return TypedPendingResourceArray.new(values, Array([], TYPE_OBJECT, script.get_instance_base_type(), script))
	
	return Array(values, TYPE_OBJECT, script.get_instance_base_type(), script)


func _parse_constructor(value: String) -> Variant:
	var script_name := value.get_slice("(", 0).trim_suffix(")")
	
	var args := _parse_value_list(value.trim_prefix(script_name + "(").trim_suffix(")"))
	
	return Constructor.new(script_name).construct(args)


func _parse_value_list(value_list: String) -> Array:
	value_list = value_list.strip_edges()
	if value_list.begins_with("(") and value_list.ends_with(")"):
		value_list = value_list.trim_prefix("(").trim_suffix(")").strip_edges()
	return Array(Stringifier.split_ignoring_nested(value_list, ",")).map(func(value: String) -> Variant:
		value = value.strip_edges()
		
		if value.begins_with("(") and value.ends_with(")"):
			return _parse_value_list(value)
		
		return _parse_value(value)
	)


## Encodes all saved data into a [String].
func encode_to_text() -> String:
	var result := ""
	var stream := encode_to_stream()
	while true:
		var value = stream.get_next()
		if stream.is_finished():
			return result
		result += value
	return result


func encode_to_file(file: FileAccess) -> void:
	var stream := encode_to_stream()
	while true:
		var value = stream.get_next()
		if stream.is_finished():
			return
		file.store_string(value)


func encode_to_stream() -> ValueStream:
	var stream := ValueStream.new()
	_stream_encode(stream)
	return stream


func _stream_encode(stream: ValueStream) -> void:
	await stream.start()
	
	var resources := _prepare_resource_list()
	
	var ext_resources: Array[Resource] = []
	var sub_resources: Array[Resource] = []
	for resource in resources:
		if resource.resource_path.is_empty() or "::" in resource.resource_path:
			sub_resources.append(resource)
		else:
			ext_resources.append(resource)
	
	ext_resources.sort_custom(func(a: Resource, b: Resource) -> bool: return a.resource_path < b.resource_path)
	
	for ext_resource in ext_resources:
		await stream.step("[ext_resource path=\"%s\" id=\"%s\"]\n" % [
			ext_resource.resource_path,
			_stringify_uid(_resource_get_uid(ext_resource)),
		])
	if not ext_resources.is_empty():
		await stream.step("\n")
	for sub_resource in sub_resources:
		processing_owner_stack.append(sub_resource)
		
		var script := sub_resource.get_script() as Script
		if script:
			await stream.step("[sub_resource script=\"%s\" id=\"%s\"]\n" % [
				UserClassDB.script_get_identifier(script),
				_stringify_uid(_resource_get_uid(sub_resource))
			])
		else:
			await stream.step("[sub_resource class=\"%s\" id=\"%s\"]\n" % [
				sub_resource.get_class(),
				_stringify_uid(_resource_get_uid(sub_resource))
			])
		
		for property in sub_resource.get_property_list():
			if property.name == "script":
				continue
			if property.name == "resource_local_to_scene" and sub_resource.get(property.name) == false:
				continue
			if property.name == "resource_name" and sub_resource.get(property.name) == "":
				continue
			if property.usage & PROPERTY_USAGE_STORAGE:
				var value: Variant = sub_resource[property.name]
				await stream.step("%s = %s\n" % [property.name, _serialize_value(value)])
		
		await stream.step("\n")
		
		processing_owner_stack.pop_back()
	
	for script in get_scripts():
		processing_owner_stack.append(UserClassDB.class_get_script(script))
		
		await stream.step("[%s]\n" % script)
		for key in get_eternals(script):
			var value := _serialize_value(get_eternal(script, key))
			await stream.step("%s = %s\n" % [key, value])
		
		await stream.step("\n")
		
		processing_owner_stack.pop_back()
	
	assert(processing_owner_stack.is_empty(), "Processing stack did not get cleared.")
	stream.finish()


func _serialize_value(value: Variant) -> String:
	if value is Object and _is_object_packable(value):
		var script := UserClassDB.script_get_identifier(value.get_script())
		var r = value._export_packed()
		if r is Array:
			return "%s(%s)" % [
				script,
				", ".join(r.map(_serialize_value))
			]
		return "%s(%s)" % [script, r]
	
	if value is Resource:
		return "Resource(\"%s\")" % _stringify_uid(_resource_get_uid(value))
	if value is Array:
		if not value.is_typed():
			return "[" + ", ".join(value.map(_serialize_value)) + "]"
		
		var type := value.get_typed_builtin() as Variant.Type
		if type == TYPE_OBJECT:
			var script := value.get_typed_script() as Script
			if not script:
				return "Array[%s]([%s])" % [
					value.get_typed_class_name(),
					", ".join(value.map(_serialize_value))
				]
			else:
				var script_id := UserClassDB.script_get_identifier(script)
				
				for method in UserClassDB.class_get_method_list(script_id):
					if method.flags & METHOD_FLAG_STATIC:
						continue
					if method.name == "_export_packed":
						return "PackedArray[%s](%s)" % [
							script_id,
							", ".join(value.map(func(v: Object) -> String:
								var pack := _pack(v)
								if v.get_script() != script:
									if pack.match("(*)"):
										pack = UserClassDB.script_get_identifier(v.get_script()) + pack
									else:
										pack = "%s(%s)" % [UserClassDB.script_get_identifier(v.get_script()), pack]
								return pack\
							))
						]
				
				return "Array[%s]([%s])" % [
					UserClassDB.script_get_identifier(script),
					", ".join(value.map(_serialize_value))
				]
		else:
			return "Array[%s]([%s])" % [
				type_string(type),
				", ".join(value.map(_serialize_value))
			]
	if value is Dictionary:
		if value.is_empty():
			return "{}"
		return "{\n" + ",\n".join(value.keys().map(func(key: Variant) -> String:
			return _serialize_value(key) + ": " + _serialize_value(value[key])
		)) + "\n}"
	return Stringifier.stringify(value)


func _pack(value: Object) -> String:
	if value == null:
		return "<null>"
	
	var pack = value._export_packed()
	if not pack is Array:
		return _serialize_value(pack)
	
	if pack.is_empty():
		return "()"
	if pack.size() == 1:
		return _serialize_value(pack[0])
	
	return "(%s)" % [
		", ".join(pack.map(_serialize_value))
	]


func _resource_get_uid(resource: Resource) -> int:
	if resource not in _resources.values():
		var id := _generate_unique_id()
		_resources[id] = resource
		return id
	return _resources.find_key(resource)


func _generate_unique_id() -> int:
	var uid := _rng.randi()
	if uid in _resources:
		return _generate_unique_id()
	return uid


func _stringify_uid(uid: int) -> String:
	return "%08x" % uid


## Base class for all not yet available [Resource]s.
class PendingResourceBase:
	## Returns whether the underlying [Resource] can be obtained.
	@warning_ignore("unused_parameter")
	func is_ready(resources: Dictionary) -> bool:
		return false
	
	## Returns the underlying [Resource], or another [Variant] type that contains the [Resource].
	@warning_ignore("unused_parameter")
	func create(resources: Dictionary) -> Variant:
		return null
	
	static func _is_ready_safe(value: Variant, resources: Dictionary) -> bool:
		return not value is PendingResourceBase or value.is_ready(resources)


## A [Resource] that is not yet available.
class PendingResource extends PendingResourceBase:
	var id := -1  ## The unique id assigned to the [Resource] when it was saved.
	
	@warning_ignore("shadowed_variable")
	func _init(id: int) -> void:
		self.id = id
	
	## Returns whether a [Resource] with this [Resource]'s [member id] exists.
	func is_ready(resources: Dictionary) -> bool:
		return id in resources
	
	## Returns the [Resource] with this object's [member id].
	func create(resources: Dictionary) -> Resource:
		return resources[id]


## An [Array] of values, where at least one is an unavailable [Resource].
class UntypedPendingResourceArray extends PendingResourceBase:
	var array := []  ## The [Array] of values.
	
	@warning_ignore("shadowed_variable")
	func _init(array: Array) -> void:
		self.array = array
	
	## Returns whether all [PendingResourceBase]s in this [Array] are ready.
	func is_ready(resources: Dictionary) -> bool:
		return not array.any(func(a: Variant) -> bool: return a is PendingResourceBase and not a.is_ready(resources))
	
	## Returns this [Array], after creating all of its [PendingResourceBase]s.
	func create(resources: Dictionary) -> Array:
		return array.map(func(a: Variant) -> Variant:
			if a is PendingResourceBase:
				return a.create(resources)
			return a
		)


## A typed [Array] of potentially unavailable [Resource]s.
class TypedPendingResourceArray extends UntypedPendingResourceArray:
	var array_base: Array  ## The base of the [Array]. It should be typed, and this same [Array] will be returned in [method create].
	
	@warning_ignore("shadowed_variable")
	func _init(array: Array, array_base: Array) -> void:
		super(array)
		self.array_base = array_base
	
	## Returns [member array_base], after assigning it this [Array]'s contents.
	func create(resources: Dictionary) -> Array:
		array_base.assign(super(resources))
		return array_base


class PendingResourceDictionary extends PendingResourceBase:
	var dict := {}
	
	@warning_ignore("shadowed_variable")
	func _init(dict: Dictionary) -> void:
		self.dict = dict
	
	func is_ready(resources: Dictionary) -> bool:
		return dict.keys().all(_is_ready_safe.bind(resources)) and dict.values().all(_is_ready_safe.bind(resources))
	
	func create(resources: Dictionary) -> Dictionary:
		for key in dict.keys():
			if dict[key] is PendingResourceBase:
				dict[key] = dict[key].create(resources)
			if key is PendingResourceBase:
				dict[key.create(resources)] = dict[key]
				dict.erase(key)
		return dict


class PendingResourceInstantiator extends PendingResourceBase:
	var instantiator: Callable
	var args: Array
	
	@warning_ignore("shadowed_variable")
	func _init(instantiator: Callable, args: Array) -> void:
		self.instantiator = instantiator
		self.args = args
	
	func is_ready(resources: Dictionary) -> bool:
		return args.all(_is_ready_safe.bind(resources))
	
	func create(resources: Dictionary) -> Object:
		for i in args.size():
			if args[i] is PendingResourceBase:
				args[i] = args[i].create(resources)
		return instantiator.callv(args)


class MissingExtResource extends Resource:
	var path := ""


class ValueStream:
	var _value: Variant = null
	var _finished := false : get = is_finished
	signal _queried()
	
	func get_next() -> Variant:
		_queried.emit()
		if _finished:
			return null
		return _value
	
	func step(next: Variant) -> void:
		_value = next
		await _queried
	
	func start() -> void:
		_finished = false
		await _queried
	
	func finish() -> void:
		_finished = true
	
	func is_finished() -> bool:
		return _finished


class Constructor:
	var script_name: String
	var instantiator: Callable
	var add_script_name: bool
	var pack_args: bool
	
	@warning_ignore("shadowed_variable")
	func _init(script_name: String) -> void:
		self.script_name = script_name
		
		var script := UserClassDB.class_get_script(script_name)
		if "_import_packed_static_v" in script and script._import_packed_static_v is Callable:
			instantiator = script._import_packed_static_v
			add_script_name = true
			pack_args = true
		elif "_import_packed_static" in script and script._import_packed_static is Callable:
			instantiator = script._import_packed_static
			add_script_name = true
			pack_args = false
		elif "_import_packed_v" in script and script._import_packed_v is Callable:
			instantiator = script._import_packed_v
			add_script_name = false
			pack_args = true
		elif "_import_packed" in script and script._import_packed is Callable:
			instantiator = script._import_packed
			add_script_name = false
			pack_args = false
		else:
			instantiator = script.new
			add_script_name = false
			pack_args = false
	
	func construct(args: Array = []) -> Object:
		if pack_args:
			if args.any(func(v: Variant) -> bool: return v is PendingResourceBase):
				args = [UntypedPendingResourceArray.new(args)]
			else:
				args = [args]
		if add_script_name:
			args.push_front(script_name)
		
		if args.any(func(v: Variant) -> bool: return v is PendingResourceBase):
			return PendingResourceInstantiator.new(instantiator, args)
		
		return instantiator.callv(args)
