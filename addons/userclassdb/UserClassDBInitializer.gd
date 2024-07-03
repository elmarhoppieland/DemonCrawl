extends Node

# ==============================================================================
var _class_map := {}
# ==============================================================================

func _ready() -> void:
	for class_data in ProjectSettings.get_global_class_list():
		_class_map[class_data.path] = class_data.class
	
	_init_dir("res://")


func _init_dir(dir: String) -> void:
	for file in DirAccess.get_files_at(dir):
		if file.get_extension() != "gd":
			continue
		
		var path := dir.path_join(file)
		var resource = ResourceLoader.load(path)
		if not resource is Script:
			push_error("Error loading script at path '%s'." % path)
			continue
		var script := resource as Script
		
		var id: String = _class_map[path] if path in _class_map else path
		
		UserClassDB._classes[id] = script
		
		_init_script(script, id)
	
	for subdir in DirAccess.get_directories_at(dir):
		if subdir.begins_with("."):
			continue
		
		_init_dir(dir.path_join(subdir))


func _init_script(script: Script, base_id: String) -> void:
	if script in UserClassDB._classes:
		return
	
	var constants := script.get_script_constant_map()
	for constant: String in constants:
		var value = constants[constant]
		if value is Script and value.resource_path.is_empty():
			var id := base_id + ":" + constant
			UserClassDB._classes[id] = value
			_init_script(value, id)
