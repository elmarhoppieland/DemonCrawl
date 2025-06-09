@tool
#extends StaticClass
class_name Eternity

# ==============================================================================
const DEFAULTS_FILE_PATH := "res://.data/Eternity/defaults.cfg"
# ==============================================================================
static var _defaults_cfg := EternalFile.new()

static var path := "" :
	set(value):
		var different := path != value
		path = value
		if different:
			_reload_file()

static var _named_paths := {}
#static var _named_values := {}

static var saved: Signal :
	get:
		return _Instance.saved
static var loaded: Signal :
	get:
		return _Instance.loaded

#static var _save_cfg: EternalFile = null

static var _initialized := false

static var _named_path_load_queue := PackedStringArray()

static var _processing_cfg: EternalFile = null : get = get_processing_file
static var _processing_owner: Object = null : get = get_processing_owner
# ==============================================================================

static func _static_init() -> void:
	if Engine.is_editor_hint():
		return
	
	if _initialized:
		return
	
	_initialized = true
	
	if ProjectSettings.has_setting("eternity/named_paths/defaults"):
		_named_paths = ProjectSettings.get_setting("eternity/named_paths/defaults")
	
	if OS.is_debug_build():
		_defaults_cfg.load_existing_resources.call_deferred(DEFAULTS_FILE_PATH)
		
		while true:
			await _defaults_cfg.value_changed
			await Promise.defer() # this makes sure we never save more than once per frame (unless any values get changed in deferred calls after this)
			_defaults_cfg.save(DEFAULTS_FILE_PATH, true)
	else:
		_defaults_cfg.load.call_deferred(DEFAULTS_FILE_PATH)


static func _editor_init() -> void:
	if ProjectSettings.has_setting("eternity/editor/editor_save_path") and not ProjectSettings.get_setting("eternity/editor/editor_save_path").is_empty():
		var editor_save_file := EternalFile.new()
		editor_save_file.load(ProjectSettings.get_setting("eternity/editor/editor_save_path"))
		
		for script_name in editor_save_file.get_scripts():
			var script := UserClassDB.class_get_script(script_name)
			for eternal in editor_save_file.get_eternals(script_name):
				script.set(eternal, editor_save_file.get_eternal(script_name, eternal))


static func get_saved_value(save_path: String, script: Script, key: String) -> Variant:
	var script_class := UserClassDB.script_get_identifier(script)
	var cfg := EternalFile.new()
	cfg.load(save_path)
	return cfg.get_eternal(script_class, key, _defaults_cfg.get_eternal(script_class, key))


static func save(path_name: String = "") -> void:
	if Engine.is_editor_hint():
		return
	
	var file_path := _get_path(path_name)
	
	if file_path.is_empty():
		return
	
	var file := EternalFile.new()
	_processing_cfg = file
	
	file.clear()
	
	for script_class in _defaults_cfg.get_scripts():
		var script := UserClassDB.class_get_script(script_class)
		for key in _defaults_cfg.get_eternals(script_class):
			var name := key.get_slice("::", 0) if "::" in key else ""
			if name != path_name:
				continue
			
			key = key.trim_prefix(name + "::")
			
			var value = script.get(key)
			
			if script.has_method("_export_" + key.lstrip("_")):
				value = script.call("_export_" + key.lstrip("_"))
			
			file.set_eternal(script_class, key, value)
			
			#if section not in _named_values:
				#if path_name.is_empty():
					#file.set_value(section, key, value)
			#elif key in _named_values[section] and _named_values[section][key] == path_name:
				#file.set_value(section, key, value)
	
	_processing_owner = null
	
	file.save(file_path, OS.is_debug_build())
	
	_processing_cfg = null
	
	#for named_path in named_cfgs:
		#var cfg: EternalFile = named_cfgs[named_path]
		#cfg.save(_named_paths[named_path])
	
	saved.emit(file_path)


static func get_processing_owner() -> Object:
	if _processing_cfg and not _processing_cfg.processing_owner_stack.is_empty():
		return _processing_cfg.processing_owner_stack[-1]
	return _processing_owner


static func get_processing_file() -> EternalFile:
	return _processing_cfg


static func get_save_name(path_name: String = "") -> String:
	return _get_path(path_name).get_file().get_basename()


static func get_defaults_cfg() -> EternalFile:
	if Engine.is_editor_hint():
		_defaults_cfg.load(DEFAULTS_FILE_PATH)
	return _defaults_cfg


static func _get_path(path_name: String = "") -> String:
	if path_name.is_empty():
		return path
	if path_name not in _named_paths:
		#Debug.log_error("")
		return ""
	
	return _named_paths[path_name]


static func _reload_file(path_name: String = "") -> void:
	var file_path := _get_path(path_name)
	var prefix := "" if path_name.is_empty() else (path_name + "::")
	if file_path.is_empty():
		return
	
	var cfg := EternalFile.new()
	_processing_cfg = cfg
	cfg.load(file_path)
	
	for script_class in _defaults_cfg.get_scripts():
		var script := UserClassDB.class_get_script(script_class)
		_processing_owner = script
		assert(is_instance_valid(script))
		for key in _defaults_cfg.get_eternals(script_class):
			if "::" in key:
				if key.get_slice("::", 0) != path_name:
					continue
				key = key.get_slice("::", 1)
			elif not path_name.is_empty():
				continue
			
			if key not in script:
				push_error("Invalid key '%s' under section '%s': Could not find the key in the class." % [key, script_class])
				continue
			
			var value: Variant
			if cfg.has_eternal(script_class, key):
				value = cfg.get_eternal(script_class, key)
			else:
				value = _duplicate(_defaults_cfg.get_eternal(script_class, prefix + key))
			
			if script.has_method("_import_" + key):
				value = script.call("_import_" + key, value)
			
			script.set(key, value)
	
	_processing_owner = null
	
	loaded.emit(file_path)
	_processing_cfg = null


static func _queue_named_path_load(path_name: String) -> void:
	if path_name in _named_path_load_queue:
		return
	_named_path_load_queue.append(path_name)
	
	await Promise.defer()
	
	_reload_file(path_name)
	assert(path_name in _named_path_load_queue, "Unexpected result; investigate and add conditional return")
	_named_path_load_queue.remove_at(_named_path_load_queue.find(path_name))


static func _duplicate(value: Variant) -> Variant:
	match typeof(value):
		TYPE_ARRAY, TYPE_DICTIONARY, TYPE_PACKED_BYTE_ARRAY, TYPE_PACKED_COLOR_ARRAY,\
		TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_FLOAT64_ARRAY, TYPE_PACKED_INT32_ARRAY,\
		TYPE_PACKED_INT64_ARRAY, TYPE_PACKED_STRING_ARRAY, TYPE_PACKED_VECTOR2_ARRAY,\
		TYPE_PACKED_VECTOR3_ARRAY:
			return value.duplicate()
		_:
			return value


class _Instance:
	static var _instance := _Instance.new()
	static var path_changed: Signal :
		get:
			return _instance._path_changed
	static var saved: Signal :
		get:
			return _instance._saved
	static var loaded: Signal :
		get:
			return _instance._loaded
	
	signal _path_changed()
	signal _saved(path: String)
	signal _loaded(path: String)
