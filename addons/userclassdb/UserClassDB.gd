extends Object
class_name UserClassDB

## An information repository for user-defined classes.
##
## Provides access to metadata stored for every available user-defined class.
## [br][br]
## Classes that are defined using [code]class_name[/code] will be available under
## their custom name. Other classes are available under their script path.
## [br][br]
## [b]Note:[/b] Only user-defined classes are available here. Built-in classes are
## available in [ClassDB].

# ==============================================================================
static var _classes := {} :
	get:
		if not _initialized:
			push_warning("Attempted to use the UserClassDB before it is ready.")
		return _classes
static var _initialized := false

static var ready: Signal : ## Emitted when the database is ready to be read from.
	get:
		return _Instance.ready
# ==============================================================================

func _init() -> void:
	assert(false, "Instantiating UserClassDB is not allowed. Instead, call methods on the class directly.")


## Returns [code]true[/code] if objects can be instantiated from the specified class,
## otherwise returns [code]false[/code].
static func class_can_instantiate(name: StringName) -> bool:
	return class_exists(name) and class_get_script(name).can_instantiate()


## Returns whether the specified class is available or not.
static func class_exists(name: StringName) -> bool:
	return name in _classes


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
	var methods: Array[Dictionary] = script.get_script_method_list()
	
	if no_inheritance:
		return methods
	
	var parent := get_parent_class(name)
	if parent.is_empty():
		return methods
	
	return methods + class_get_method_list(parent)


## Returns the value of [code]property[/code] of [code]object[/code] or its ancestry.
static func class_get_property(object: Object, property: StringName) -> Variant:
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
	
	var parent := get_parent_class(name)
	if parent.is_empty():
		return property_list
	
	return property_list + class_get_property_list(parent)


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
static func get_class_list() -> PackedStringArray:
	return _classes.keys()


## Returns the names of all the classes that directly or indirectly inherit from class [code]name[/code].
static func get_inheriters_from_class(name: StringName) -> PackedStringArray:
	if not class_exists(name):
		return []
	
	var script := class_get_script(name)
	return _classes.keys().filter(func(c: StringName): return class_get_script(c).get_base_script() == script)


## Returns the parent class of the given class.
static func get_parent_class(name: StringName) -> StringName:
	if class_exists(name):
		var parent_script := class_get_script(name).get_base_script()
		if parent_script in _classes.values():
			return _classes.find_key(parent_script)
	
	return &""


## Creates an instance of class [code]name[/code].
static func instantiate(name: StringName) -> Object:
	if not class_can_instantiate(name):
		return null
	
	if not class_exists(name):
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
		return class_get_script(name).get_instance_base_type() == inherits
	
	return class_get_script(name).get_base_script() == class_get_script(inherits)


## Returns class [code]name[/code]'s [Script] instance.
static func class_get_script(name: StringName) -> Script:
	return _classes.get(name)


## Returns the class name of [code]script[/code].
static func get_class_from_script(script: Script) -> StringName:
	var key = _classes.find_key(script)
	if key == null:
		return &""
	return key


## Returns all subclasses defined under the base class [code]name[/code].
## [br][br]All elements of the returned array will be the full name of the subclass,
## including the name of the base class, e.g. [code]BaseClass:SubClass[/code].
static func class_get_subclasses(name: StringName) -> PackedStringArray:
	return _classes.keys().filter(func(key: StringName): return key.begins_with(name + ":"))


## Returns whether the database has been initialized.
static func is_ready() -> bool:
	return _initialized


class _Instance:
	static var _instance := _Instance.new()
	static var ready: Signal :
		get:
			return _instance._ready
	
	signal _ready()
