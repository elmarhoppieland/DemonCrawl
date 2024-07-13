@tool
extends EditorPlugin
class_name Eternity

# ==============================================================================
const DEFAULTS_FILE_PATH := "res://.data/eternity/defaults.cfg"
# ==============================================================================
static var _defaults_cfg := EternalFile.new()

static var path := "" :
	set(value):
		var different := path != value
		path = value
		if different:
			_reload_file()

static var saved: Signal :
	get:
		return _Instance.saved
static var loaded: Signal :
	get:
		return _Instance.loaded

static var _save_cfg: EternalFile
# ==============================================================================

func _enter_tree() -> void:
	add_autoload_singleton("__EternityInitializer", "res://addons/eternity/EternityInitializer.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("__EternityInitializer")


static func save() -> void:
	if path.is_empty():
		return
	
	_save_cfg.clear()
	
	for section in _defaults_cfg.get_sections():
		var script := UserClassDB.class_get_script(section)
		for key in _defaults_cfg.get_section_keys(section):
			var value = script.get(key)
			
			if script.has_method("_export_" + key):
				value = script.call("_export_" + key, value)
			
			_save_cfg.set_value(section, key, value)
	
	_save_cfg.save(path)
	
	saved.emit()


static func get_save_name() -> String:
	return path.get_file().get_basename()


static func _reload_file() -> void:
	if path.is_empty():
		return
	
	_save_cfg = EternalFile.new()
	_save_cfg.load(path)
	
	for section in _defaults_cfg.get_sections():
		var script := UserClassDB.class_get_script(section)
		for key in _defaults_cfg.get_section_keys(section):
			if not key in script:
				push_error("Invalid key '%s' under section '%s': Could not find the key in the class." % [key, section])
				continue
			
			var value = _save_cfg.get_value(section, key, _defaults_cfg.get_value(section, key))
			if script.has_method("_import_" + key):
				value = script.call("_import_" + key, value)
			
			script.set(key, value)
	
	loaded.emit()


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
	signal _saved()
	signal _loaded()
