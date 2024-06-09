extends Object
class_name SavesManager

# ==============================================================================
const SETTINGS_PATH := "user://settings.ini"
# ==============================================================================
static var save_path := "" :
	set(value):
		var different := save_path != value
		save_path = value
		if different:
			_reload_file()

static var _save_cfg: ConfigFile
static var _references := {} # [-->] {<reference_object>: {<prop_name>: <prop_default>}}
static var _settings_cfg: ConfigFile
static var _settings_references := {} # [-->] {<reference_object>: {<prop_name>: <prop_default>}}
# ==============================================================================

static func bind_setting(name: String, reference: Object, default: Variant) -> void:
	if reference in _settings_references:
		_settings_references[reference][name] = default
	else:
		_settings_references[reference] = {name: default}


static func get_setting(name: String, reference: Object, default: Variant) -> Variant:
	if Engine.is_editor_hint():
		return default
	
	bind_setting(name, reference, default)
	
	if not _settings_cfg:
		_reload_settings()
	
	return _settings_cfg.get_value(_get_reference_name(reference), name, default)


static func _reload_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
		Debug.log_event("Settings file at path '%s' did not exist. Created a new file." % SETTINGS_PATH, Color.CORAL)
	
	_settings_cfg = ConfigFile.new()
	_settings_cfg.load(SETTINGS_PATH)
	
	Debug.log_event("Loaded settings from path '%s'." % SETTINGS_PATH, Color.CORAL)


static func bind_value(name: String, reference: Object, default: Variant) -> void:
	if reference in _references:
		_references[reference][name] = default
	else:
		_references[reference] = {name: default}


static func get_value(name: String, reference: Object, default: Variant) -> Variant:
	if Engine.is_editor_hint():
		return default
	
	bind_value(name, reference, default)
	
	if not _save_cfg:
		_reload_file()
		if not _save_cfg:
			return default
	
	var result := _get_file_value(name, reference)
	if not result.found:
		return default
	return result.value


static func get_save_name() -> String:
	if Engine.is_editor_hint():
		return ""
	
	return save_path.get_file().get_basename()


static func save() -> void:
	if save_path.is_empty():
		return
	
	if not _save_cfg:
		_save_cfg = ConfigFile.new()
	
	for reference in _references:
		for name in _references[reference]:
			var value = reference[name]
			
			if reference.has_method("_export_" + name):
				value = reference.call("_export_" + name)
			elif value is Object and value.has_method("_export") and not value is EditorImportPlugin:
				value = value._export()
			
			_save_cfg.set_value(_get_reference_name(reference), name, value)
	
	_save_cfg.save(save_path)
	
	Debug.log_event("Saved the current data to disk (at path '%s')" % save_path, Color.DARK_SALMON)


static func save_settings() -> void:
	for reference in _settings_references:
		for name in _settings_references[reference]:
			var value = reference[name]
			
			if reference.has_method("_export_" + name):
				value = reference.call("_export_" + name)
			
			_settings_cfg.set_value(_get_reference_name(reference), name, value)
	
	_settings_cfg.save(SETTINGS_PATH)
	
	Debug.log_event("Saved the settings to disk (at path '%s')" % SETTINGS_PATH, Color.DARK_SALMON)


#static func get_file_data(path: String) -> Dictionary:
	#var file := FileAccess.open(path, FileAccess.READ)
	#if not file:
		#push_error("Could not open file '%s': %s" % [path, error_string(FileAccess.get_open_error())])
		#return {}
	#
	#var json = JSON.parse_string(file.get_as_text())
	#if not json is Dictionary:
		#push_error("File '%s' does not contain a JSON Dictionary." % path)
		#return {}
	#
	#return json


#static func _get_reference(name: Variant) -> Object:
	#return _references.get(name)


static func _get_reference_name(reference: Object) -> String:
	if "name" in reference and (reference.name is String or reference.name is StringName):
		return reference.name
	elif reference is Resource:
		return reference.resource_path.get_file().get_basename()
	
	Debug.log_error("Could not obtain the reference name of the given reference '%s'." % reference)
	return ""


static func _get_file_value(key: String, reference: Object) -> FileValueResult:
	if not _save_cfg:
		_reload_file()
	
	if not _save_cfg.has_section_key(_get_reference_name(reference), key):
		return FileValueResult.new(false)
	
	var value = _save_cfg.get_value(_get_reference_name(reference), key)
	if reference.has_method("_import_" + key):
		value = reference.call("_import_" + key, value)
	else:
		var result := _import_value_from_reference(reference, key, value)
		if result.found:
			value = result.value
	
	return FileValueResult.new(true, value)


static func _reload_file() -> void:
	if save_path.is_empty():
		return
	
	_save_cfg = ConfigFile.new()
	
	if FileAccess.file_exists(save_path):
		_save_cfg.load(save_path)
	
	for reference: Object in _references:
		for key: String in _references[reference]:
			var result := _get_file_value(key, reference)
			if not result.found:
				assert(key in reference, "Member '%s' not found on the reference. This likely means get_value() is incorrectly called. Make sure the value name matches the property name." % key)
				reference[key] = _references[reference][key]
				continue
			
			reference[key] = result.value
	
	Debug.log_event("Loaded from the save at path '%s'" % save_path, Color.CORAL)


static func _import_value_from_reference(reference: Object, key: String, value: Variant) -> ImportResult:
	var ref_script: Script = reference if reference is Script else reference.get_script()
	
	if not ref_script:
		return ImportResult.new(false)
	
	for prop in ref_script.get_property_list():
		if prop.name == key:
			if prop.type == TYPE_ARRAY and prop.hint == PROPERTY_HINT_ARRAY_TYPE:
				var result := _import_typed_array_from_reference(value, prop)
				if result:
					return result
			
			if prop.class_name.is_empty():
				return ImportResult.new(false)
			
			var script := _get_custom_class_script(prop.class_name)
			if not script:
				Debug.log_error("The property on reference '%s' was found and has class name '%s', but this class was not found." % [reference, prop.class_name])
				return ImportResult.new(false)
			
			if script.has_method("_import"):
				return ImportResult.new(true, script._import(value))
			
			return ImportResult.new(false)
	
	Debug.log_error("Could not find key '%s' as a property on reference '%s'." % [key, reference])
	return ImportResult.new(false)


static func _import_typed_array_from_reference(value: Variant, prop: Dictionary) -> ImportResult:
	var script := _get_custom_class_script(prop.hint_string)
	if not script:
		return null
	
	if script.has_method("_import"):
		var r := Array([], TYPE_OBJECT, script.get_instance_base_type(), script)
		r.assign(value.map(func(element: Variant):
			return script._import(element))
		)
		
		return ImportResult.new(true, r)
	
	return ImportResult.new(false)


static func _get_custom_class_script(custom_class: StringName) -> Script:
	for class_data in ProjectSettings.get_global_class_list():
		if class_data.class == custom_class:
			return ResourceLoader.load(class_data.path)
	
	Debug.log_error("Could not find custom class '%s'." % custom_class)
	return null


class SavesValue:
	var property_name := ""
	var owner: Object
	var default: Variant = null
	
	var importer := Callable()
	var exporter := Callable()
	
	
	func load_from_file(file: ConfigFile) -> void:
		if file.has_section_key(get_owner_name(), property_name):
			owner[property_name] = file.get_value(get_owner_name(), property_name)
		else:
			owner[property_name] = default
	
	func get_owner_name() -> String:
		if "name" in owner and (owner.name is String or owner.name is StringName):
			return owner.name
		elif owner is Resource:
			return owner.resource_path.get_file().get_basename()
		
		Debug.log_error("Could not obtain the owner name of the owner '%s'." % owner)
		return ""


class FileValueResult:
	var found := false
	var value: Variant = null
	
	func _init(_found: bool, _value: Variant = null) -> void:
		found = _found
		value = _value


class ImportResult:
	var value: Variant = null
	var found := true
	
	func _init(_found: bool, _value: Variant = null) -> void:
		value = _value
		found = _found
