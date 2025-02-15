@tool
extends Object
class_name UserClassDB

## An information repository for user-defined classes.
##
## Provides access to metadata stored for every available user-defined class.
## [br][br]
## Classes that are defined using [code]class_name[/code] will be available under
## both their custom name and their script path. Other classes are available under
## their script path.
## [br][br]
## If a class has any subclasses defined (using [code]class MySubClass[/code]), that
## subclass is available under [code]BaseClass:MySubClass[/code]. If the base script
## does not have a class name defined, the path can be used instead.
## [br][br]
## [b]Examples:[/b]
## [codeblock]
## # Returns true if the class 'MyClass' exists.
## UserClassDB.class_exists("MyClass")
##
## # Returns true if a script exists at the given path.
## UserClassDB.class_exists("res://scripts/my_class.gd")
##
## # Returns true if MyClass exists and has a subclass named 'MySubClass'.
## UserClassDB.class_exists("MyClass:MySubClass")
##
## # Returns true if my_class.gd exists and has a subclass 'MySubClass' with a subclass 'MySubSubClass'.
## UserClassDB.class_exists("res://scripts/my_class.gd:MySubClass:MySubSubClass")
## [/codeblock]
## [codeblock]
## # Obtains the class name of the caller's script.
## UserClassDB.script_get_class(get_script())
##
## # Obtains all subclasses defined in the caller's script.
## UserClassDB.class_get_subclasses(UserClassDB.script_get_class(get_script()))
## [/codeblock]
## [b]Note:[/b] Only user-defined classes are available here. Built-in classes are
## available in [ClassDB].

# ==============================================================================
static var _classes := {}
static var _initialized := false

static var _frozen_classes := {}

static var _script_id_cache := {}
# ==============================================================================

func _init() -> void:
	assert(false, "Instantiating UserClassDB is not allowed. Instead, call methods on the class directly.")


## If [code]name[/code] is the name if a user-defined class, or points to a subclass
## of a user-defined class name, converts the class name into the path to
## the class's script.
static func class_get_path(name: StringName) -> StringName:
	if name.is_absolute_path():
		return name
	
	if ":" in name.trim_prefix("res://"):
		return class_get_path(name.get_slice(":", 0)) + name.substr(name.find(":"))
	
	for class_data in ProjectSettings.get_global_class_list():
		if class_data.class == name:
			return class_data.path
	
	return &""


## If [code]path[/code] is the path to a script that has a class name, or points
## to a subclass of a script with a class name, converts the path into the script's
## class name. If no class name is defined, returns the original path.
static func class_get_name(path: StringName) -> StringName:
	if ":" in path.trim_prefix("res://"):
		return class_get_name(path.substr(0, path.rfind(":"))) + path.substr(path.rfind(":"))
	
	for class_data in ProjectSettings.get_global_class_list():
		if class_data.path == path:
			return class_data.class
	
	return path


## Returns whether the specified class is available or not.
static func class_exists(name: StringName) -> bool:
	name = class_get_path(name)
	
	if OS.get_thread_caller_id() in _frozen_classes:
		return name in _frozen_classes[OS.get_thread_caller_id()]
	
	if not Engine.is_editor_hint() and name in _classes:
		return true
	
	if ResourceLoader.exists(name):
		_classes[name] = load(String(name))
		return true
	
	if ":" in name.trim_prefix("res://"):
		return class_exists(name.substr(0, name.rfind(":")))
	
	return false


## Returns [code]true[/code] if objects can be instantiated from the specified class,
## otherwise returns [code]false[/code].
static func class_can_instantiate(name: StringName) -> bool:
	return class_exists(name) and class_get_script(name).can_instantiate()


## Returns an array with all the keys in enum of class or its ancestry.
static func class_get_enum_constants(name: StringName, enum_name: StringName, no_inheritance: bool = false) -> PackedStringArray:
	if not class_exists(name):
		return []
	
	var script := class_get_script(name)
	var constants := script.get_script_constant_map()
	if enum_name in constants:
		if constants[enum_name] is Dictionary:
			var keys: Array = constants[enum_name].keys()
			if keys.all(func(k: Variant): return k is String):
				return keys
		
		return []
	
	if no_inheritance:
		return []
	
	var parent := get_parent_class(name)
	if parent.is_empty():
		return []
	
	return class_get_enum_constants(parent, enum_name)


## Returns an array with all the enums of class or its ancestry.
static func class_get_enum_list(name: StringName, no_inheritance: bool = false) -> PackedStringArray:
	if not class_exists(name):
		return []
	
	var script := class_get_script(name)
	var constants := script.get_script_constant_map()
	var enums := PackedStringArray(constants.keys().filter(func(a: String) -> bool:
		var value = constants[a]
		if not value is Dictionary:
			return false
		
		var keys = value.keys()
		
		return keys.all(func(k: Variant): return k is String)
	))
	
	if no_inheritance:
		return enums
	
	var parent := get_parent_class(name)
	if parent.is_empty():
		return enums
	
	return enums + class_get_enum_list(parent)


## Returns the value of the integer constant [code]int_name[/code] of class [code]name[/code]
## or its ancestry. Always returns 0 when the constant could not be found.
static func class_get_integer_constant(name: StringName, int_name: StringName) -> int:
	if not class_exists(name):
		return 0
	
	var script := class_get_script(name)
	var constants := script.get_script_constant_map()
	if int_name in constants:
		var value = constants[int_name]
		if value is int:
			return value
	
	var parent := get_parent_class(name)
	if parent.is_empty():
		return 0
	
	return class_get_integer_constant(parent, int_name)


## Returns which enum the integer constant [code]int_name[/code] of class [code]name[/code]
## or its ancestry belongs to.
static func class_get_integer_constant_enum(name: StringName, int_name: StringName, no_inheritance: bool = false) -> StringName:
	if not class_exists(name):
		return &""
	
	for enum_name in class_get_enum_list(name, no_inheritance):
		if int_name in enum_name:
			return enum_name
	
	return &""


## Returns an array with the names all the integer constants of class [code]name[/code]
## or its ancestry.
static func class_get_integer_constant_list(name: StringName, no_inheritance: bool = false) -> PackedStringArray:
	if not class_exists(name):
		return []
	
	var script := class_get_script(name)
	var constants := script.get_script_constant_map()
	var int_constants: PackedStringArray = constants.keys().filter(func(a: String) -> bool:
		return constants[a] is int
	)
	
	if no_inheritance:
		return int_constants
	
	var parent := get_parent_class(name)
	if parent.is_empty():
		return int_constants
	
	return int_constants + class_get_integer_constant_list(name)


## Returns an array with all the methods of class or its ancestry if [code]no_inheritance[/code]
## is [code]false[/code]. Every element of the array is a [Dictionary] with the following
## keys: [code]args, default_args, flags, id, name, return: (class_name, hint, hint_string, name, type, usage)[/code].
## [br][br][b]Note:[/b] In exported release builds the debug info is not available,
## so the returned dictionaries will contain only method names.
static func class_get_method_list(name: StringName, no_inheritance: bool = false) -> Array[Dictionary]:
	if not class_exists(name):
		return []
	
	var script := class_get_script(name)
	var methods := script.get_script_method_list()
	
	if no_inheritance:
		return methods
	
	var parent := get_parent_class(name)
	if parent.is_empty():
		return methods
	
	var method_names := methods.map(func(method: Dictionary) -> String: return method.name)
	return methods + class_get_method_list(parent).filter(func(method: Dictionary) -> bool: return not method.name in method_names)


## Returns the value of [code]property[/code] of [code]object[/code] or its ancestry.
static func class_get_property(object: Object, property: StringName) -> Variant:
	# this seems too trivial but I'm guessing GDScript uses ClassDB behind the scenes here
	return object[property]


## Returns an array with all the properties of class [code]name[/code] or its ancestry
## if [code]no_inheritance[/code] is [code]false[/code].
static func class_get_property_list(name: StringName, no_inheritance: bool = false) -> Array[Dictionary]:
	if not class_exists(name):
		return []
	
	var script := class_get_script(name)
	var property_list := script.get_script_property_list()
	
	if no_inheritance:
		return property_list
	
	var base := script.get_base_script()
	while base != null:
		property_list.append_array(base.get_script_property_list())
		base = base.get_base_script()
	
	return property_list


## Returns the signal data of class [code]name[/code] or its ancestry. The returned
## value is a [Dictionary] with the following keys: [code]args, default_args, flags,
## id, name, return: (class_name, hint, hint_string, name, type, usage)[/code].
static func class_get_signal(name: StringName, signal_name: StringName) -> Dictionary:
	if not class_exists(name):
		return {}
	
	var script := class_get_script(name)
	var signals := script.get_script_signal_list()
	
	for s in signals:
		if s.name == signal_name:
			return s
	
	return {}


## Returns an array with all the signals of class or its ancestry if [code]no_inheritance[/code]
## is [code]false[/code]. Every element of the array is a [Dictionary] as described in
## [method class_get_signal].
static func class_get_signal_list(name: StringName, no_inheritance: bool = false) -> Array[Dictionary]:
	if not class_exists(name):
		return []
	
	var script := class_get_script(name)
	var signals := script.get_script_signal_list()
	
	if no_inheritance:
		return signals
	
	var parent := get_parent_class(name)
	if parent.is_empty():
		return signals
	
	return signals + class_get_signal_list(parent)


## Returns whether class [code]name[/code] or its ancestry has an enum called
## [code]enum_name[/code] or not.
static func class_has_enum(name: StringName, enum_name: StringName, no_inheritance: bool = false) -> bool:
	if not class_exists(name):
		return false
	
	var script := class_get_script(name)
	var constants := script.get_script_constant_map()
	if enum_name in constants:
		var value = constants[enum_name]
		if not value is Dictionary:
			return false
		if not value.keys().all(func(a): return a is String):
			return false
		
		return true
	
	if no_inheritance:
		return false
	
	var parent := get_parent_class(name)
	if parent.is_empty():
		return false
	
	return class_has_enum(parent, enum_name)


## Returns whether class [code]name[/code] or its ancestry has an integer constant called
## [code]int_name[/code] or not.
static func class_has_integer_constant(name: StringName, int_name: StringName) -> bool:
	if not class_exists(name):
		return false
	
	var script := class_get_script(name)
	var constants := script.get_script_constant_map()
	if int_name in constants:
		var value = constants[int_name]
		return value is int
	
	var parent := get_parent_class(name)
	if parent.is_empty():
		return false
	
	return class_has_integer_constant(parent, int_name)


## Returns whether class [code]name[/code] (or its ancestry if [code]no_inheritance[/code]
## is [code]false[/code]) has a method called [code]method[/code] or not.
static func class_has_method(name: StringName, method: StringName, no_inheritance: bool = false) -> bool:
	if not class_exists(name):
		return false
	
	var script := class_get_script(name)
	var methods := script.get_script_method_list()
	for method_data in methods:
		if method_data.name == method:
			return true
	
	if no_inheritance:
		return false
	
	var parent := get_parent_class(name)
	if parent.is_empty():
		return false
	
	return class_has_method(parent, method)


## Returns whether class [code]name[/code] or its ancestry has a signal called
## [code]signal_name[/code] or not.
static func class_has_signal(name: StringName, signal_name: StringName) -> bool:
	if not class_exists(name):
		return false
	
	var script := class_get_script(name)
	var signals := script.get_script_signal_list()
	for signal_data in signals:
		if signal_data.name == signal_name:
			return true
	
	return false


## Returns whether class [code]name[/code] or its ancestry has a property named [code]property[/code].
static func class_has_property(name: StringName, property: StringName, no_inheritance: bool = false) -> bool:
	if not class_exists(name):
		return false
	
	for prop in class_get_property_list(name, no_inheritance):
		if prop.name == property:
			return true
	
	return false


## Sets [code]property[/code] value of [code]object[/code] to [code]value[/code].
static func class_set_property(object: Object, property: StringName, value: Variant) -> Error:
	if not property in object:
		return ERR_UNAVAILABLE
	
	object.set(property, value)
	return OK


## Returns the names of all the classes available.
## [br][br][b]Note:[/b] When called for the first time, will fetch all avaiable classes
## in the filesystem and their subclasses and cache the results. Future calls will then
## use the cache instead.
## [br][br][b]Note:[/b] When called from the editor, this will always re-fetch all
## classes so that the class list is always updated. This is not needed during runtime
## as long as no scripts are created during runtime.
static func get_class_list() -> PackedStringArray:
	if not _initialized:
		reload_classes()
		
		if Engine.is_editor_hint():
			(func(): UserClassDB._initialized = false).call_deferred()
	
	if OS.get_thread_caller_id() in _frozen_classes:
		return _frozen_classes[OS.get_thread_caller_id()].keys()
	
	return _classes.keys()


static func reload_classes() -> void:
	if OS.get_thread_caller_id() in _frozen_classes:
		return
	
	_classes.clear()
	
	for path in _get_files_in_dir_recursive("res://", "*.gd"):
		_classes[path] = load(path)
		
		for subclass in class_get_subclasses(path, true):
			_classes[subclass] = class_get_script(subclass)
	
	_initialized = true


static func _get_files_in_dir_recursive(dir: String, pattern: String = "*") -> PackedStringArray:
	var files := PackedStringArray()
	
	var dir_files := DirAccess.get_files_at(dir)
	if ".gdignore" in dir_files:
		return []
	
	for file in dir_files:
		if not file.match(pattern):
			continue
		
		files.append(dir.path_join(file))
	
	for subdir in DirAccess.get_directories_at(dir):
		files.append_array(_get_files_in_dir_recursive(dir.path_join(subdir), pattern))
	
	return files


## Returns the names of all the classes that directly or indirectly inherit from class [code]name[/code].
static func get_inheriters_from_class(name: StringName) -> PackedStringArray:
	var inheriters := PackedStringArray()
	
	if ClassDB.class_exists(name):
		for c in get_class_list():
			var script := class_get_script(c)
			if not script:
				continue
			if script.get_instance_base_type() == name:
				inheriters.append(c)
	elif class_exists(name):
		for c in get_class_list():
			if is_parent_class(c, name):
				inheriters.append(c)
	
	return inheriters


## Returns the parent class of the given class.
static func get_parent_class(name: StringName) -> StringName:
	if not class_exists(name):
		return &""
	
	var script := class_get_script(name)
	var parent_script := class_get_script(name).get_base_script()
	return script_get_identifier(parent_script) if parent_script else script.get_instance_base_type()


## Creates an instance of class [code]name[/code].
static func instantiate(name: StringName, disable_safety_checks: bool = false) -> Object:
	if not disable_safety_checks and not class_can_instantiate(name):
		return null
	
	return class_get_script(name).new()


## Returns whether class [code]name[/code] is enabled or not.
static func is_class_enabled(name: StringName) -> bool:
	return class_exists(name)


## Returns whether [code]inherits[/code] is an ancestor of class [code]name[/code] or not.
static func is_parent_class(name: StringName, inherits: StringName) -> bool:
	if not class_exists(name):
		return false
	if not class_exists(inherits):
		return ClassDB.is_parent_class(class_get_script(name).get_instance_base_type(), inherits)
	
	var script := class_get_script(inherits)
	var base := class_get_script(name)
	while base != null:
		base = base.get_base_script()
		if base == script:
			return true
	
	return false
	#return class_get_script(name).get_base_script() == class_get_script(inherits) or is_parent_class(name, get_parent_class(inherits))


## Returns class [code]name[/code]'s [Script] instance.
static func class_get_script(name: StringName) -> Script:
	name = class_get_path(name)
	
	if not class_exists(name):
		return null
	
	if ":" in name.trim_prefix("res://"):
		return class_get_script(name.substr(0, name.rfind(":")))[name.get_slice(":", name.count(":"))]
	
	return ResourceLoader.load(String(name))
	
	#return _classes.get(class_get_path(name))


## Returns the class name of [code]script[/code].
## [br][br][b]Note:[/b] Returns an empty [StringName] if the provided script does not have
## a class name defined. If you need an identifier for the script, use [method script_get_identifier].
static func script_get_class(script: Script) -> StringName:
	for class_data in ProjectSettings.get_global_class_list():
		if class_data.path == script.resource_path:
			return class_data.class
		for subclass in class_get_subclasses(class_data.path):
			if class_get_script(subclass) == script:
				return class_data.class + subclass.substr(subclass.find(":", 6))
	
	return &""


## Returns an identifier for [code]script[/code]. The identifier can then be used in
## UserClassDB's functions.
## [br][br]If [code]use_class_if_available[/code] is [code]true[/code], will use
## the script's class name (or the class name of its base script if it is a subclass),
## if it is defined.
## [br][br][b]Note:[/b] If the script has a defined class name, this method will return
## the same value as [method script_get_class].
## [br][br][b]Note:[/b] This method is a slower version of [method script_get_class]
## if [code]script[/code] has a class name, so prefer using [method script_get_class]
## over this method if the script is guaranteed to have a class name. This is because
## this method needs to fetch all classes, while [method script_get_class] can use
## [ProjectSettings]'s global class list.
static func script_get_identifier(script: Script, use_class_if_available: bool = true) -> StringName:
	if script in _script_id_cache and not Engine.is_editor_hint():
		return _script_id_cache[script]
	
	var id := &""
	
	for name in get_class_list():
		if class_get_script(name) == script:
			id = name
			break
	
	if use_class_if_available:
		for class_data in ProjectSettings.get_global_class_list():
			if class_data.path == id.substr(0, id.find(":", 6)):
				id = class_data.class + id.substr(id.find(":", 6))
				_script_id_cache[script] = id
				return id
	
	_script_id_cache[script] = id
	return id


## Returns all subclasses defined under the base class [code]name[/code].
## [br][br]All elements of the returned array will be the full name of the subclass,
## including the name of the base class, e.g. [code]BaseClass:SubClass[/code], not just
## [code]SubClass[/code].
static func class_get_subclasses(name: StringName, recursive: bool = false) -> PackedStringArray:
	var original_name := name
	name = class_get_path(name)
	
	if not class_exists(name):
		return []
	
	var subclasses := PackedStringArray()
	
	if OS.get_thread_caller_id() in _frozen_classes:
		for c in get_class_list():
			if c.begins_with(name + ":"):
				subclasses.append(c)
		
		return subclasses
	
	var script := class_get_script(name)
	var constants := script.get_script_constant_map()
	for constant: String in constants:
		var value = constants[constant]
		if value is Script and value.resource_path.is_empty():
			_classes[name + ":" + constant] = value
			subclasses.append(original_name + ":" + constant)
			
			if recursive:
				subclasses.append_array(class_get_subclasses(name + ":" + constant, recursive))
	
	return subclasses


static func freeze_class_list_on_thread(thread_id: int = OS.get_thread_caller_id()) -> void:
	reload_classes()
	_frozen_classes[thread_id] = _classes.duplicate()


static func unfreeze_class_list_on_thread(thread_id: int = OS.get_thread_caller_id()) -> void:
	_frozen_classes.erase(thread_id)
