extends RefCounted
class_name EternalFile

## Helper class to write [Eternal]s to disk.

# ==============================================================================
var _data := {}
var _resources := {}
# ==============================================================================
signal value_changed(section: String, key: String, value: Variant)
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
		return
	
	var file := FileAccess.open(path, FileAccess.READ)
	_parse_ini(file)


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


## Returns a [PackedStringArray] of all [Script]s that have any [Eternal]s.
func get_scripts() -> PackedStringArray:
	var scripts := PackedStringArray()
	for key in _data:
		if _data[key].is_empty():
			continue
		if UserClassDB.class_exists(key):
			scripts.append(key)
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
	if value is Resource:
		if value in _resources.values():
			return value
		
		_resource_get_uid(value)
		for property in value.get_property_list():
			if property.name == "script":
				continue
			if property.usage & PROPERTY_USAGE_STORAGE:
				var property_value = value[property.name]
				if property_value is Resource:
					_store_resource(property_value)
	elif value is Array:
		for i in value:
			_store_resource(i)
	return value


func _prepare_resource_list() -> void:
	var resources: Array[Resource] = []
	resources.assign(_resources.values())
	var i := 0
	while i < resources.size():
		var resource := resources[i]
		if not resource.resource_path.is_empty():
			i += 1
			continue
		
		for property in resource.get_property_list():
			if property.name == "script":
				continue
			if property.usage & PROPERTY_USAGE_STORAGE:
				var value = resource.get(property.name)
				_prepare_variant(value, resources)
		
		_resource_get_uid(resource)
		i += 1


func _prepare_variant(variant: Variant, resources: Array[Resource]) -> void:
	if variant is Resource and variant not in resources:
		resources.append(variant)
	elif variant is Array:
		_prepare_array(variant, resources)
	elif variant is Dictionary:
		_prepare_dictionary(variant, resources)


func _prepare_array(array: Array, resources: Array[Resource]) -> void:
	for v in array:
		_prepare_variant(v, resources)


func _prepare_dictionary(dict: Dictionary, resources: Array[Resource]) -> void:
	for key in dict:
		_prepare_variant(key, resources)
		_prepare_variant(dict[key], resources)


func _parse_ini(file: FileAccess) -> void:
	_data.clear()
	
	var current_section := ""
	var current_resource: Resource = null
	while not file.eof_reached():
		var line := _read_line(file)
		
		if line.begins_with("[") and line.ends_with("]"):
			current_section = line.substr(1, line.length() - 2).strip_edges()
			if current_section.begins_with("ext_resource "):
				var id := current_section.get_slice("id=\"", 1).get_slice("\"", 0).hex_to_int()
				assert(id not in _resources, "Duplicate ID found in the file at '%s'." % file.get_path())
				var resource := load(current_section.get_slice("path=\"", 1).get_slice("\"", 0))
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
	
	_data[current_section][key] = await _await_resource(_parse_value(value))


func _parse_resource_line(line: String, current_resource: Resource, file_path: String) -> void:
	if "#" in line:
		line = line.substr(0, line.find("#")).strip_edges()
	if line.is_empty():
		return
	
	var key := line.get_slice("=", 0).strip_edges()
	var value := line.trim_prefix(key).strip_edges().trim_prefix("=").strip_edges()
	assert("=" in line, "Invalid line '%s' in file '%s'." % [line, file_path])
	
	if key not in current_resource:
		push_warning("Invalid property '%s' under resource '%s' in file '%s': Property not found." % [key, UserClassDB.script_get_identifier(current_resource.get_script()), file_path])
		return
	
	var parsed_value = _parse_value(value)
	if parsed_value is PendingResourceBase:
		while not parsed_value.is_ready(_resources):
			await _resource_saved
		parsed_value = parsed_value.create(_resources)
	
	current_resource[key] = await _await_resource(_parse_value(value))


func _await_resource(resource: Variant) -> Variant:
	if not resource is PendingResourceBase:
		return resource
	
	while not resource.is_ready(_resources):
		await _resource_saved
	return resource.create(_resources)


func _validate_value_string(value: String) -> bool:
	if value[0] == "{":
		return value[-1] == "}"
	if value[0] == "[":
		return value[-1] == "]"
	if value.begins_with("Array["):
		return value.ends_with("])")
	return true


func _parse_value(value: String) -> Variant:
	value = value.strip_edges()
	
	if value.is_valid_int():
		return value.to_int()
	elif value.is_valid_float():
		return value.to_float()
	elif value == "true":
		return true
	elif value == "false":
		return false
	elif value == "null":
		return null
	elif value.begins_with("\"") and value.ends_with("\""):
		return value.substr(1, value.length() - 2)
	elif value.begins_with("Resource(\"") and value.ends_with("\")"):
		var id := value.get_slice("\"", 1).hex_to_int()
		if id in _resources:
			return _resources[id]
		return PendingResource.new(id)
	elif value.match("[*]"):
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
			values.append(v)
		if is_pending:
			return UntypedPendingResourceArray.new(values)
		return Array(values_string).map(_parse_value)
	elif value.match("Array[*]([*])"):
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
				values.append(v)
			if is_pending:
				return TypedPendingResourceArray.new(values, Array([], TYPE_OBJECT, script.get_instance_base_type(), script))
			return Array(values, TYPE_OBJECT, script.get_instance_base_type(), script)
		var type := range(TYPE_MAX).map(func(t: int) -> String: return type_string(t)).find(type_name)
		assert(type != -1, "Invalid class name in value '%s'." % value)
		return Array(Array(value.substr(9 + type_name.length()).trim_suffix("])").split(",")).map(_parse_value), type, "", null)
	elif value.match("{*}"):
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
			dict[key] = parsed_value
		if is_pending:
			return PendingResourceDictionary.new(dict)
		return dict
	return Stringifier.parse(value)


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
		await stream.step("[ext_resource path=\"%s\" id=\"%s\"]\n\n" % [
			ext_resource.resource_path,
			_stringify_uid(_resource_get_uid(ext_resource)),
		])
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
	if value is Resource:
		return "Resource(\"%s\")" % _stringify_uid(_resource_get_uid(value))
	if value is Array:
		if value.is_typed():
			var type := value.get_typed_builtin() as Variant.Type
			if type == TYPE_OBJECT:
				var script := value.get_typed_script() as Script
				return "Array[%s]([%s])" % [
					UserClassDB.script_get_identifier(script) if script else value.get_typed_class_name(),
					", ".join(value.map(_serialize_value))
				]
			else:
				return "Array[%s]([%s])" % [
					type_string(type),
					", ".join(value.map(_serialize_value))
				]
		return "[" + ", ".join(value.map(_serialize_value)) + "]"
	if value is Dictionary:
		if value.is_empty():
			return "{}"
		return "{\n" + ",\n".join(value.keys().map(func(key: Variant) -> String:
			return _serialize_value(key) + ": " + _serialize_value(value[key])
		)) + "\n}"
	return Stringifier.stringify(value)


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
