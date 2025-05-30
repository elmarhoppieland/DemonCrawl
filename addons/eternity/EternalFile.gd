extends RefCounted
class_name EternalFile

## Helper class to write [Eternal]s to disk.

# ==============================================================================
var current_resource: Resource = null
# ==============================================================================
var _data := {}
var _resources := {}
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
func load(path: String) -> void:
	if not FileAccess.file_exists(path):
		_data.clear()
		_resources.clear()
		
		loaded.emit(path)
		return
	
	var file := FileAccess.open(path, FileAccess.READ)
	_parse_ini(file)
	
	loaded.emit(path)


## Saves the loaded data to [code]path[/code].
func save(path: String) -> void:
	if not DirAccess.dir_exists_absolute(path.get_base_dir()):
		DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("Could not open file '%s': %s" % [path, error_string(FileAccess.get_open_error())])
		return
	#file.store_line(encode_to_text())
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
	#var identifier: String = UserClassDB.script_get_identifier(script)
	if script in _data:
		return PackedStringArray(_data[script].keys())
	return PackedStringArray()


## Returns the saved value of the [Eternal] in the given [code]script[/code],
## with the given [code]key[/code]. If it is not available, returns [code]default[/code],
## or [code]null[/code] if the parameter is omitted.
func get_eternal(script: String, key: String, default: Variant = null) -> Variant:
	#var identifier: String = UserClassDB.script_get_identifier(script)
	if script not in _data or key not in _data[script]:
		return default
	
	return _data[script][key]


## Sets the value of the [Eternal] in the given [code]script[/code] with the given
## [code]key[/code] to [code]value[/code].
func set_eternal(script: String, key: String, value: Variant) -> void:
	#var identifier: String = UserClassDB.script_get_identifier(script)
	if script not in _data:
		_data[script] = {}
	
	_data[script][key] = _store_resource(value)
	value_changed.emit(script, key, value)


func has_eternal(script: String, key: String) -> bool:
	#var identifier := UserClassDB.script_get_identifier(script)
	return script in _data and key in _data[script]


func _store_resource(value: Variant) -> Variant:
	var resources: Array[Resource] = []
	_prepare_variant(value, resources)
	for resource in resources:
		_resource_get_uid(resource)
	
	return value


func _prepare_resource_list() -> void:
	var resources: Array[Resource] = []
	resources.assign(_resources.values())
	var i := 0
	while i < resources.size():
		var resource := resources[i]
		if not resource.resource_path.is_empty():
			_resource_get_uid(resource)
			i += 1
			continue
		
		for property in resource.get_property_list():
			if property.name == "script":
				continue
			if resource.has_method("_export_" + property.name):
				continue
			if property.usage & PROPERTY_USAGE_STORAGE:
				var value = resource.get(property.name)
				_prepare_variant(value, resources)
		
		_resource_get_uid(resource)
		i += 1


func _prepare_variant(variant: Variant, resources: Array[Resource]) -> void:
	if variant is Object and variant.has_method("_export_packed"):
		return
	
	if variant is Resource and variant not in resources:
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


func _is_packable(value: Variant) -> bool:
	if not value is Array or not value.is_typed():
		return false
	
	var script := value.get_typed_script() as Script
	if not script:
		return false
	
	var base := script
	while base:
		for method in base.get_script_method_list():
			if method.flags & METHOD_FLAG_STATIC:
				continue
			if method.name == "_export_packed":
				return true
		
		base = base.get_base_script()
	
	
	return false


func _parse_ini(file: FileAccess) -> void:
	_data.clear()
	_resources.clear()
	
	current_resource = null
	
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
					_resources[id] = load(path)
				else:
					var resource := MissingExtResource.new()
					resource.path = path
					_resources[id] = resource
				
				current_section = ""
				continue
			
			if current_section.begins_with("sub_resource "):
				var id := current_section.get_slice("id=\"", 1).get_slice("\"", 0).hex_to_int()
				assert(id not in _resources, "Duplicate ID found in the file at '%s'." % file.get_path())
				if current_section.match("* script=\"*\"*"):
					var script := UserClassDB.class_get_script(current_section.get_slice("script=\"", 1).get_slice("\"", 0))
					current_resource = script.new()
				elif current_section.match("* class=\"*\"*"):
					current_resource = ClassDB.instantiate(current_section.get_slice("class=\"", 1).get_slice("\"", 0))
				_resources[id] = current_resource
				_resource_saved.emit(id)
				continue
			
			current_resource = null
			_data[current_section] = {}
			continue
		
		if current_resource:
			_parse_resource_line(line, current_resource, file.get_path())
		else:
			_parse_script_line(line, current_section, file.get_path())


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


func _parse_script_line(line: String, current_section: String, file_path: String) -> void:
	if "#" in line:
		line = line.substr(0, line.find("#")).strip_edges()
	if line.is_empty():
		return
	
	if current_section.is_empty():
		var key := line.get_slice("=", 0).strip_edges()
		var value := line.trim_prefix(key).strip_edges().trim_prefix("=").strip_edges()
		push_warning("Key-value pair '%s'-'%s' found outside of a section in file '%s'. Continuing..." % [key, value])
		return
	
	var key := line.get_slice("=", 0).strip_edges()
	var value := line.trim_prefix(key).strip_edges().trim_prefix("=").strip_edges()
	assert("=" in line, "Invalid line '%s' in file '%s'." % [line, file_path])
	
	_data[current_section][key] = await await_resource(_parse_value(value))


@warning_ignore("shadowed_variable")
func _parse_resource_line(line: String, current_resource: Resource, file_path: String) -> void:
	if "#" in line:
		line = line.substr(0, line.find("#")).strip_edges()
	if line.is_empty():
		return
	
	var key := line.get_slice("=", 0).strip_edges()
	var value := line.trim_prefix(key).strip_edges().trim_prefix("=").strip_edges()
	assert("=" in line, "Invalid line '%s' in file '%s'." % [line, file_path])
	
	#var parsed_value = _parse_value(value)
	#if parsed_value is PendingResourceBase:
		#while not parsed_value.is_ready(_resources):
			#await _resource_saved
		#parsed_value = parsed_value.create(_resources)
	
	current_resource.set(key, await await_resource(_parse_value(value)))


func await_resource(resource: Variant) -> Variant:
	if not resource is PendingResourceBase:
		return resource
	
	while not resource.is_ready(_resources):
		await _resource_saved
	return resource.create(_resources)


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
	
	var instantiator: Callable
	var add_script_name: bool
	if script.has_method("_import_packed_static"):
		instantiator = script._import_packed_static
		add_script_name = true
	elif script.has_method("_import_packed"):
		instantiator = script._import_packed
		add_script_name = false
	else:
		instantiator = script.new
		add_script_name = false
	
	var values := []
	
	var is_pending := false
	for s in Stringifier.split_ignoring_nested(value.trim_prefix("PackedArray[" + script_name + "]" + "(").trim_suffix(")"), ","):
		s = s.strip_edges()
		
		var s_script_name: String
		var s_instantiator: Callable
		var s_add_script_name: bool
		if not s.begins_with("(") and s.match("*(*)"):
			s_script_name = s.get_slice("(", 0)
			var s_script := UserClassDB.class_get_script(s_script_name)
			
			if s_script.has_method("_import_packed_static"):
				s_instantiator = s_script._import_packed_static
				s_add_script_name = true
			elif s_script.has_method("_import_packed"):
				s_instantiator = s_script._import_packed
				s_add_script_name = false
			else:
				s_instantiator = s_script.new
				s_add_script_name = false
		else:
			s_script_name = script_name
			s_instantiator = instantiator
			s_add_script_name = add_script_name
		
		s = s.trim_prefix(s_script_name).trim_prefix("(").trim_suffix(")").strip_edges()
		
		if s == "<null>":
			values.append(null)
			continue
		
		var arg_strings := Stringifier.split_ignoring_nested(s, ",")
		
		var args := []
		if s_add_script_name:
			args.append(s_script_name)
		var parsed_args := Array(arg_strings).map(_parse_value)
		args.append_array(parsed_args)
		if parsed_args.any(func(a: Variant) -> bool: return a is PendingResourceBase):
			is_pending = true
			values.append(PendingResourceInstantiator.new(s_instantiator, parsed_args))
		else:
			var instance: Object = s_instantiator.callv(args)
			values.append(instance)
	
	if is_pending:
		return TypedPendingResourceArray.new(values, Array([], TYPE_OBJECT, script.get_instance_base_type(), script))
	
	return Array(values, TYPE_OBJECT, script.get_instance_base_type(), script)


func _parse_constructor(value: String) -> Variant:
	var script_name := value.get_slice("(", 0).trim_suffix(")")
	var script := UserClassDB.class_get_script(script_name)
	
	var instantiator: Callable
	var add_script_name: bool
	var pack_args: bool
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
	
	var args := _parse_value_list(value.trim_prefix(script_name + "(").trim_suffix(")"))
	if pack_args:
		args = [args]
	if add_script_name:
		args.push_front(script_name)
	
	if args.any(func(v: Variant) -> bool: return v is PendingResourceBase):
		return PendingResourceInstantiator.new(instantiator, args)
	
	return instantiator.callv(args)


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


#func encode_to_text() -> String:
	#var result := ""
	#var ext_resources: Array[Resource] = []
	#var sub_resources: Array[Resource] = []
	#
	#_prepare_resource_list()
	#
	#for id in _resources:
		#var resource: Resource = _resources[id]
		#if resource.resource_path.is_empty():
			#sub_resources.append(resource)
		#else:
			#ext_resources.append(resource)
	#
	#for ext_resource in ext_resources:
		#result += "[ext_resource path=\"%s\" id=\"%s\"]\n\n" % [
			#ext_resource.resource_path,
			#_stringify_uid(_resource_get_uid(ext_resource)),
		#]
	#for sub_resource in sub_resources:
		#var script := sub_resource.get_script() as Script
		#if script:
			#result += "[sub_resource script=\"%s\" id=\"%s\"]\n" % [
				#UserClassDB.script_get_identifier(script),
				#_stringify_uid(_resource_get_uid(sub_resource))
			#]
		#else:
			#result += "[sub_resource class=\"%s\" id=\"%s\"]\n" % [
				#sub_resource.get_class(),
				#_stringify_uid(_resource_get_uid(sub_resource))
			#]
		#
		#for property in sub_resource.get_property_list():
			#if property.name == "script":
				#continue
			#if property.usage & PROPERTY_USAGE_STORAGE:
				#var value: Variant = sub_resource[property.name]
				#result += "%s = %s\n" % [property.name, _serialize_value(value)]
		#
		#result += "\n"
	#
	#for script in get_scripts():
		#result += "[%s]\n" % script
		#for key in get_eternals(script):
			#var value := _serialize_value(get_eternal(script, key))
			#result += "%s = %s\n" % [key, value]
		#result += "\n"
	#return result.strip_edges()


#func encode_to_file(file: FileAccess) -> void:
	#var ext_resources: Array[Resource] = []
	#var sub_resources: Array[Resource] = []
	#
	#_prepare_resource_list()
	#
	#for id in _resources:
		#var resource: Resource = _resources[id]
		#if resource.resource_path.is_empty():
			#sub_resources.append(resource)
		#else:
			#ext_resources.append(resource)
	#
	#for ext_resource in ext_resources:
		#file.store_line("[ext_resource path=\"%s\" id=\"%s\"]\n" % [
			#ext_resource.resource_path,
			#_stringify_uid(_resource_get_uid(ext_resource)),
		#])
	#for sub_resource in sub_resources:
		#var script := sub_resource.get_script() as Script
		#if script:
			#file.store_line("[sub_resource script=\"%s\" id=\"%s\"]" % [
				#UserClassDB.script_get_identifier(script),
				#_stringify_uid(_resource_get_uid(sub_resource))
			#])
		#else:
			#file.store_line("[sub_resource class=\"%s\" id=\"%s\"]" % [
				#sub_resource.get_class(),
				#_stringify_uid(_resource_get_uid(sub_resource))
			#])
		#
		#for property in sub_resource.get_property_list():
			#if property.name == "script":
				#continue
			#if property.usage & PROPERTY_USAGE_STORAGE:
				#var value: Variant = sub_resource[property.name]
				#file.store_line("%s = %s" % [property.name, _serialize_value(value)])
		#
		#file.store_line("")
	#
	#for script in get_scripts():
		#file.store_line("[%s]" % script)
		#for key in get_eternals(script):
			#var value := _serialize_value(get_eternal(script, key))
			#file.store_line("%s = %s" % [key, value])
		#
		#file.store_line("")


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
	
	var ext_resources: Array[Resource] = []
	var sub_resources: Array[Resource] = []
	
	_prepare_resource_list()
	
	for id in _resources:
		var resource: Resource = _resources[id]
		if resource.resource_path.is_empty():
			sub_resources.append(resource)
		else:
			ext_resources.append(resource)
	
	for ext_resource in ext_resources:
		await stream.step("[ext_resource path=\"%s\" id=\"%s\"]\n" % [
			ext_resource.resource_path,
			_stringify_uid(_resource_get_uid(ext_resource)),
		])
	if not ext_resources.is_empty():
		await stream.step("\n")
	for sub_resource in sub_resources:
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
		
		current_resource = sub_resource
		
		for property in sub_resource.get_property_list():
			if property.name == "script":
				continue
			if property.usage & PROPERTY_USAGE_STORAGE:
				var value: Variant = sub_resource[property.name]
				await stream.step("%s = %s\n" % [property.name, _serialize_value(value)])
		
		await stream.step("\n")
	
	for script in get_scripts():
		await stream.step("[%s]\n" % script)
		for key in get_eternals(script):
			var value := _serialize_value(get_eternal(script, key))
			await stream.step("%s = %s\n" % [key, value])
		
		await stream.step("\n")
	
	stream.finish()


func _serialize_value(value: Variant) -> String:
	if value is Object and value.has_method("_export_packed"):
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
	var uid := randi()
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
