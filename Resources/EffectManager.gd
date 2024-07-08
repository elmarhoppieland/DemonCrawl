extends StaticClass
class_name EffectManager

## Helper class for propagating calls.
##
## The [EffectManager] can progatate calls to all registered objects. Propagate a
## call using [method propagate_call].
## [br][br]Instead of propagating a call, the [EffectManager] can also propagate values.
## The given method is called for each registered object (if it exists on the object),
## and each call will update the value.
## [br][br]See [EffectDocs] for a list of all available effects.

# ==============================================================================
# NOTE: whenever iterating over this array when unregistering objects may happen while iterating,
# first duplicate() it so unregistering objects is safe
static var _objects: Array[WeakRef] = [] :
	get:
		if not _initialized:
			_initialized = true
			_initialize.call_deferred()
		return _objects

static var _connections_reactive := {}
static var _connections_influencing := {}

static var _initialized := false
# ==============================================================================

static func _initialize() -> void:
	if OS.is_debug_build():
		_register_directory("res://", FileAccess.open("res://.data/EffectManager.files", FileAccess.WRITE))
	else:
		var file := FileAccess.open("res://.data/EffectManager.files", FileAccess.READ)
		while not file.eof_reached():
			var path := file.get_line()
			if path.is_empty():
				continue
			register_object(ResourceLoader.load(path).new())


static func _register_directory(dir: String, file: FileAccess) -> void:
	for file_name in DirAccess.get_files_at(dir):
		if not file_name.get_extension() == "gd":
			continue
		
		var path := dir.path_join(file_name)
		var script := ResourceLoader.load(path)
		if not script is Script:
			continue
		
		var base := (script as Script).get_base_script()
		while base != null and base != EffectScript:
			base = base.get_base_script()
		if base == null:
			continue
		
		file.store_line(path)
		register_object(script.new())
	
	for dir_name in DirAccess.get_directories_at(dir):
		if dir_name.begins_with("."):
			continue
		
		var path := dir.path_join(dir_name)
		_register_directory(path, file)


## Registers [code]object[/code]. Future calls to [method propagate_call],
## [method propagate_value] or [method propagate_posnum] will be passed into the
## given object.
## [br][br]If [code]allow_duplicates[/code] is [code]false[/code], the object
## will not be registered if it has already been registered. If [code]allow_duplicates[/code]
## is [code]true[/code] and the object was already registered, propagating calls
## will be passed into the object once for each time it has been registered.
## This can be useful to allow objects to trigger an extra time.
static func register_object(object: Object, allow_duplicates: bool = false) -> void:
	if allow_duplicates or _objects.all(func(o: WeakRef): return o.get_ref() != object):
		_objects.append(weakref(object))


## Unregisters [code]object[/code]. Future calls to [method propagate_call],
## [method propagate_value] or [method propagate_posnum] will no longer be passed
## into the given object.
## [br][br]If the object was registered multiple times, it will only be unregistered
## once. Future propagations will only be passed one fewer time for each time
## the object gets unregistered.
static func unregister_object(object: Object) -> void:
	for i in _objects.size():
		if _objects[i].get_ref() == object:
			_objects.remove_at(i)
			break


## Connects a [Callable] to an effect. The effect the callable connects to is the
## name of the method. When passing a member function, this is the name of the function.
## When passing a lambda function, this is the lambda name.
## [br][br]If [code]influencing[/code] is [code]false[/code], the callable will
## not influence values passed into [method propagate_value] or [method propagate_posnum].
## If [code]influencing[/code] is [code]true[/code], the callable [b]will[/b]
## be able to influence values.
## [br][br]If the effect the callable gets connected to is a reactive effect
## (one called via [method propagate_call]), [code]influencing[/code] must be [code]false[/code].
## [br][br]If [code]allow_duplicates[/code] is [code]false[/code], the callable
## will not be connected if it has already been connected. If [code]allow_duplicates[/code]
## is [code]true[/code] and the callable was already connected, the callable will
## be called once for each time it has been connected.
## [br][br]If the parameter [code]effect[/code] overridden, connects to the given
## effect instead of the callable's name.
## [br][br][b]Note:[/b] All lambda functions passed into this method should be named.
## Anonymous lambdas will be connected, but will never be called.
## [br][br][b]Note:[/b] This will only connect a single method to a single effect.
## To connect to all effects, use [method register_object] on the callable's object.
static func connect_effect(callable: Callable, influencing: bool = false, allow_duplicates: bool = false, effect: StringName = &"") -> void:
	if effect.is_empty():
		effect = callable.get_method()
	
	var dict := _connections_influencing if influencing else _connections_reactive
	
	if effect in dict:
		if callable in dict[effect] and not allow_duplicates:
			return
		dict[effect].append(callable)
	else:
		dict[effect] = [callable]


## Disconnects a [Callable] from an effect. The provided callable must be the same
## callable as the one passed into [method connect_effect].
## [br][br]If the callable was connected multiple times, it will only be disconnected
## once. Future propagations will only call the callable one fewer time for each time
## the callable gets disconnected.
## [br][br]If the parameter [code]effect[/code] overridden, disconnects from the given
## effect instead of the callable's name.
static func disconnect_effect(callable: Callable, influencing: bool = false, effect: StringName = callable.get_method()) -> void:
	var dict := _connections_influencing if influencing else _connections_reactive
	
	if effect in dict:
		dict[effect].erase(callable)
		if dict[effect].is_empty():
			dict.erase(effect)


## Alias for [code]propagate_value(&"change" + stat, [], value)[/code]. This ensures
## all effects use the same naming convention.
static func change_stat(stat: StringName, value: Variant) -> Variant:
	return propagate_value(&"change_" + stat, [], value)


## Propagates [code]method_name[/code] to all registered objects as a reactive effect.
## [br][br]The method will be called on all registered objects that have the
## given method. After calling methods on registered objects, will call all [Callable]s
## connected to the effect via [method connect_effect].
## [br][br][b]Note:[/b] [Callable]s connected to this effect via [method connect_effect]
## should not be influencing (i.e. parameter [code]influencing[/code] should have
## been false when they were connected). If any influencing callables are connected,
## a warning will be logged.
static func propagate_call(method_name: StringName, args: Array = []) -> void:
	if Engine.is_editor_hint():
		return
	
	for object in _get_objects():
		if not object.has_method(method_name):
			continue
		
		object.callv(method_name, args)
	
	for callable: Callable in _get_reactive_connections(method_name).duplicate():
		callable.callv(args)
	if method_name in _connections_influencing:
		Debug.log_warning("Effect %s was called as reactive, but it has influencing connection(s). Influencing effects should not be called using propagate_call()." % method_name)
		
		for callable: Callable in _get_influencing_connections(method_name).duplicate():
			callable.callv(args)
	
	_Instance.called.emit(method_name, args)


## Propagates [code]method_name[/code] to all registered objects as an influencing effect.
## [br][br]The method will be called on all registered objects that have the
## given method. After calling methods on registered objects, will call all [Callable]s
## connected to the effect via [method connect_effect].
## [br][br][code]initial_value[/code] will be passed as the first parameter in each call.
## With each call, this value will be updated to the value returned by the call.
## [br][br]Each method called should return a value of the type specified by
## [code]forced_type[/code]. If this argument was omitted, the forced type is the
## same type as [code]initial_value[/code].
## [br][br]Methods that are defined with a return type of [code]void[/code] will
## be called as reactive effects: they cannot influence the value and are called
## after all influencing effects have been called. This ensures the value passed
## into the call will always be the final value used.
static func propagate_value(method_name: StringName, args: Array, initial_value: Variant, forced_type: Variant.Type = typeof(initial_value) as Variant.Type) -> Variant:
	if Engine.is_editor_hint():
		return initial_value
	
	args.push_front(initial_value)
	
	var effect_objects := _get_objects().filter(func(o: Object): return o.has_method(method_name))
	var reactive_objects: Array[Object] = []
	for object: Object in effect_objects:
		var returns_void := false
		for method_data: Dictionary in object.get_method_list():
			if method_data.name != method_name:
				continue
			returns_void = method_data.return.type == TYPE_NIL
			break
		
		if returns_void:
			reactive_objects.append(object)
			continue
		
		var returned = object.callv(method_name, args)
		if returned == null:
			continue
		if forced_type != TYPE_NIL and typeof(returned) != forced_type:
			Debug.log_error("Method '%s' on object '%s' returned an incorrect value type. Should be '%s', but '%s' was returned." % [method_name, object, type_string(typeof(initial_value)), type_string(typeof(returned))])
			continue
		
		args[0] = returned
	
	for callable: Callable in _get_influencing_connections(method_name).duplicate():
		var returned = callable.callv(args)
		if returned == null:
			continue
		if forced_type != TYPE_NIL and typeof(returned) != forced_type:
			Debug.log_error("Callable '%s' returned an incorrect value type. Should be '%s', but '%s' was returned." % [callable.get_method(), type_string(typeof(initial_value)), type_string(typeof(returned))])
			continue
		
		args[0] = returned
	
	for object in reactive_objects:
		object.callv(method_name, args)
	
	for callable: Callable in _get_reactive_connections(method_name).duplicate():
		callable.callv(args)
	
	_Instance.called.emit(method_name, args)
	
	return args.pop_front()


## Special case of [method propagate_value]. This method will always return a non-negative numeric value.
static func propagate_posnum(method_name: StringName, args: Array, initial_value: Variant, forced_type: Variant.Type = typeof(initial_value) as Variant.Type) -> Variant:
	return max(0, propagate_value(method_name, args, initial_value, forced_type))


## Waits for the given effect to be called and then returns the arguments passed into
## the call as an [Array].
## [br][br]Should be used with [code]await[/code].
static func await_call(method_name: StringName) -> Array:
	var args := [null, null]
	
	while true:
		_Instance.called.connect(func(method: StringName, signal_args: Array):
			args[0] = method
			args[1] = signal_args
		)
		await _Instance.called
		if args[0] == method_name:
			break
	
	return args[1]


static func _get_objects() -> Array[Object]:
	_objects = _objects.filter(func(r: WeakRef): return r.get_ref() != null)
	
	return Array(_objects.map(func(r: WeakRef): return r.get_ref()), TYPE_OBJECT, "Object", null)


static func _get_reactive_connections(effect: StringName) -> Array[Callable]:
	return _get_connections_from_dict(effect, _connections_reactive)


static func _get_influencing_connections(effect: StringName) -> Array[Callable]:
	return _get_connections_from_dict(effect, _connections_influencing)


static func _get_connections_from_dict(effect: StringName, dict: Dictionary) -> Array[Callable]:
	if not effect in dict:
		return []
	
	var callables: Array[Callable] = []
	
	callables.assign(dict[effect].filter(func(callable: Callable):
		return callable.is_valid()
	))
	
	dict[effect] = callables
	
	return callables


class _Instance:
	static var _instance := _Instance.new()
	static var called: Signal :
		get:
			return _instance._called
	
	signal _called(method_name: StringName, args: Array)
