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
enum Priority {
	ENVIRONMENT,
	ITEM,
	SIGIL,
	HERO_TRIAL,
	STAGE_MOD,
	MASTERY
	# ...
}
# ==============================================================================
# NOTE: whenever iterating over this array when unregistering objects may happen while iterating,
# first duplicate() it so unregistering objects is safe
#static var _objects: Array[WeakRef] = [] :
	#get:
		#if not _initialized:
			#_initialized = true
			#_initialize.call_deferred()
		#return _objects

#static var _connections_reactive := {}
#static var _connections_influencing := {}

static var _connections := {} :
	get:
		if not _initialized:
			_initialized = true
			_initialize()
		return _connections

static var _initialized := false
# ==============================================================================

static func _initialize() -> void:
	if not UserClassDB.is_ready():
		await UserClassDB.ready
	var inheriters := UserClassDB.get_inheriters_from_class(&"EffectScript")
	for i in inheriters.size():
		var name := inheriters[i]
		register_object(UserClassDB.instantiate(name), Priority.ENVIRONMENT, i)


## Registers [code]object[/code]. Future calls to [method propagate_call],
## [method propagate_value] or [method propagate_posnum] will be passed into the
## given object.
## [br][br]The order in which effects are propagated depend on the object's
## [code]priority[/code] and [code]subpriority[/code] arguments. The object's
## [code]priority[/code] specifies what group this object belong to, as a value
## of the [enum Priority] enum. The object's [code]subpriority[/code] further specifies
## the order in which objects of the same group (priority) are called. These arguments
## should always be consistent so behaviour is deterministic.
## [br][br]If [code]allow_duplicates[/code] is [code]false[/code], the object
## will not be registered if it has already been registered. If [code]allow_duplicates[/code]
## is [code]true[/code] and the object was already registered, propagating calls
## will be passed into the object once for each time it has been registered.
## This can be useful to allow objects to trigger an extra time.
## [br][br][b]Note:[/b] This method registers all methods on the given object.
## To register only one specific [Callable], use [method connect_effect].
static func register_object(object: Object, priority: Priority, subpriority: int, allow_duplicates: bool = false) -> void:
	for method in UserClassDB.class_get_method_list(UserClassDB.get_class_from_script(object.get_script())):
		var data := connect_effect(object[method.name], priority, subpriority, method.return.type != TYPE_NIL, allow_duplicates, method.name)
		if data:
			data.set_required_arg_count(method.args.size() - method.default_args.size()).set_total_arg_count(method.args.size())
	
	#if allow_duplicates or _objects.all(func(o: WeakRef): return o.get_ref() != object):
		#_objects.append(weakref(object))


## Unregisters [code]object[/code]. Future calls to [method propagate_call],
## [method propagate_value] or [method propagate_posnum] will no longer be passed
## into the given object.
## [br][br]If the object was registered multiple times, it will only be unregistered
## once. Future propagations will only be passed one fewer time for each time
## the object gets unregistered.
static func unregister_object(object: Object) -> void:
	for effect in _connections:
		var new_arr: Array[ConnectionData] = []
		
		var found := false
		for data: ConnectionData in _connections[effect]:
			if data.get_object() != object or found:
				new_arr.append(data)
			else:
				found = true
		
		_connections[effect].assign(new_arr)
	
	#for i in _objects.size():
		#if _objects[i].get_ref() == object:
			#_objects.remove_at(i)
			#break


## Connects a [Callable] to an effect. The effect the callable connects to is the
## name of the method. When passing a member function, this is the name of the function.
## When passing a lambda function, this is the lambda name.
## [br][br]If [code]influencing[/code] is [code]false[/code], the callable will
## not influence values passed into [method propagate_value] or [method propagate_posnum].
## If [code]influencing[/code] is [code]true[/code], the callable [b]will[/b]
## be able to influence values. If the effect the callable gets connected to
## is a reactive effect (one called via [method propagate_call]), [code]influencing[/code]
## must be [code]false[/code].
## [br][br]If [code]allow_duplicates[/code] is [code]false[/code], the callable
## will not be connected if it has already been connected. If [code]allow_duplicates[/code]
## is [code]true[/code] and the callable was already connected, the callable will
## be called once for each time it has been connected.
## [br][br]If the parameter [code]effect[/code] is overridden, connects to the given
## effect instead of the callable's name.
## [br][br][b]Note:[/b] All lambda functions passed into this method should be named.
## Anonymous lambdas will be connected, but will never be called.
## [br][br][b]Note:[/b] This will only connect a single method to a single effect.
## To connect to all effects, use [method register_object] on the callable's object.
## [br][br][b]Warning:[/b] Due to a Godot bug, [method Callable.get_method] does not
## work on lambda functions that reference any of the object's members (variables
## or functions). If the object's member are needed, either override the [code]effect[/code]
## argument or use a member function instead. This bug will be fixed in Godot 4.3.
static func connect_effect(callable: Callable, priority: Priority, subpriority: int, influencing: bool = false, allow_duplicates: bool = false, effect: StringName = callable.get_method()) -> ConnectionData:
	if not allow_duplicates and effect in _connections and _connections[effect].any(func(d: ConnectionData): return d._callable == callable):
		return
	
	var data_arr: Array[ConnectionData] = []
	
	if not effect in _connections:
		_connections[effect] = data_arr
	else:
		data_arr = _connections[effect]
	
	var data := ConnectionData.new(callable)\
		.set_influencing(influencing)\
		.set_priority(priority)\
		.set_subpriority(subpriority)
	
	data_arr.append(data)
	return data
	
	#var dict := _connections_influencing if influencing else _connections_reactive
	#
	#if effect in dict:
		#if callable in dict[effect] and not allow_duplicates:
			#return
		#dict[effect].append(callable)
	#else:
		#dict[effect] = [callable]


## Disconnects a [Callable] from an effect. The provided callable must be the same
## callable as the one passed into [method connect_effect].
## [br][br]If the callable was connected multiple times, it will only be disconnected
## once. Future propagations will only call the callable one fewer time for each time
## the callable gets disconnected.
## [br][br]If the parameter [code]effect[/code] overridden, disconnects from the given
## effect instead of the callable's name.
static func disconnect_effect(callable: Callable, effect: StringName = callable.get_method()) -> void:
	if effect in _connections:
		for data: ConnectionData in _connections[effect]:
			if data._callable == callable:
				_connections[effect].erase(data)
				return
	
	#var dict := _connections_influencing if influencing else _connections_reactive
	#
	#if effect in dict:
		#dict[effect].erase(callable)
		#if dict[effect].is_empty():
			#dict.erase(effect)


## Alias for [code]propagate_value(&"change" + stat, [], value)[/code]. This ensures
## all effects use the same naming convention.
static func change_stat(stat: StringName, value: Variant) -> Variant:
	return propagate_value(&"change_" + stat, value)


## Propagates [code]effect[/code] to all registered objects as a reactive effect.
## [br][br]The method will be called on all registered objects that have the
## given method. After calling methods on registered objects, will call all [Callable]s
## connected to the effect via [method connect_effect].
## [br][br][b]Note:[/b] [Callable]s connected to this effect via [method connect_effect]
## should not be influencing (i.e. parameter [code]influencing[/code] should have
## been false when they were connected). If any influencing callables are connected,
## a warning will be logged.
static func propagate_call(effect: StringName, args: Array = []) -> void:
	if Engine.is_editor_hint():
		return
	
	#for object in _get_objects():
		#if not object.has_method(effect):
			#continue
		#
		#object.callv(effect, args)
	
	for data: ConnectionData in _get_reactive_connections(effect).duplicate():
		data.handle(args)
	
	var influencing_data_arr := _get_influencing_connections(effect)
	if not influencing_data_arr.is_empty():
		Debug.log_warning("Effect %s was called as reactive, but it has influencing connection(s). Influencing effects should not be called using propagate_call()." % effect)
		
		for data: ConnectionData in influencing_data_arr.duplicate():
			data.handle(args)


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
static func propagate_value(effect: StringName, default: Variant, args: Array = []) -> Variant:
	if Engine.is_editor_hint():
		return default
	
	var value = default
	
	#var effect_objects := _get_objects().filter(func(o: Object): return o.has_method(method_name))
	#var reactive_objects: Array[Object] = []
	#for object: Object in effect_objects:
		#var returns_void := false
		#for method_data: Dictionary in object.get_method_list():
			#if method_data.name != method_name:
				#continue
			#returns_void = method_data.return.type == TYPE_NIL
			#break
		#
		#if returns_void:
			#reactive_objects.append(object)
			#continue
		#
		#var returned = object.callv(method_name, args)
		#if returned == null:
			#continue
		#if forced_type != TYPE_NIL and typeof(returned) != forced_type:
			#Debug.log_error("Method '%s' on object '%s' returned an incorrect value type. Should be '%s', but '%s' was returned." % [method_name, object, type_string(typeof(initial_value)), type_string(typeof(returned))])
			#continue
		#
		#args[0] = returned
	
	for data: ConnectionData in _get_influencing_connections(effect).duplicate():
		value = data.handle_value(args, value)
	
	#for object in reactive_objects:
		#object.callv(method_name, args)
	
	for data: ConnectionData in _get_reactive_connections(effect).duplicate():
		data.handle_value(args, value)
	
	return value


## Special case of [method propagate_value]. This method will always return a non-negative numeric value.
static func propagate_posnum(method_name: StringName, default: Variant, args: Array = []) -> Variant:
	return max(0, propagate_value(method_name, default, args))


#static func _get_objects() -> Array[Object]:
	#_objects = _objects.filter(func(r: WeakRef): return r.get_ref() != null)
	#
	#return Array(_objects.map(func(r: WeakRef): return r.get_ref()), TYPE_OBJECT, "Object", null)


static func _get_reactive_connections(effect: StringName) -> Array[ConnectionData]:
	if not effect in _connections:
		return []
	
	_connections[effect].assign(_connections[effect].filter(func(data: ConnectionData) -> bool:
		return data.is_valid()
	))
	
	var data_arr: Array[ConnectionData] = []
	
	data_arr.assign(_connections[effect].filter(func(data: ConnectionData) -> bool:
		return not data._influencing
	))
	
	data_arr.sort_custom(func(a: ConnectionData, b: ConnectionData) -> bool:
		if a._priority == b._priority:
			return a._subpriority < b._subpriority
		return a._priority < b._priority
	)
	
	return data_arr


static func _get_influencing_connections(effect: StringName) -> Array[ConnectionData]:
	if not effect in _connections:
		return []
	
	_connections[effect].assign(_connections[effect].filter(func(data: ConnectionData) -> bool:
		return data.is_valid()
	))
	
	var data_arr: Array[ConnectionData] = []
	
	data_arr.assign(_connections[effect].filter(func(data: ConnectionData) -> bool:
		return data._influencing
	))
	
	data_arr.sort_custom(func(a: ConnectionData, b: ConnectionData) -> bool:
		if a._priority == b._priority:
			return a._subpriority < b._subpriority
		return a._priority < b._priority
	)
	
	return data_arr


static func _get_connections(effect: StringName, influencing: bool) -> Array[ConnectionData]:
	if not effect in _connections:
		return []
	
	_connections[effect].assign(_connections[effect].filter(func(data: ConnectionData) -> bool:
		return data.is_valid()
	))
	
	var data_arr: Array[ConnectionData] = []
	
	data_arr.assign(_connections[effect].filter(func(data: ConnectionData) -> bool:
		return data._influencing == influencing
	))
	
	data_arr.sort_custom(func(a: ConnectionData, b: ConnectionData) -> bool:
		if a._priority == b._priority:
			return a._subpriority < b._subpriority
		return a._priority < b._priority
	)
	
	return data_arr


class ConnectionData:
	var _callable: Callable
	var _priority := Priority.ITEM
	var _subpriority := 0
	var _influencing := false
	var _required_arg_count := -1
	var _total_arg_count := -1
	
	func _init(callable: Callable) -> void:
		_callable = callable
	
	func handle_value(args: Array = [], default: Variant = null) -> Variant:
		var value = handle([default] + args)
		if _influencing:
			return value
		
		return default
	
	func handle(args: Array = []) -> Variant:
		if _total_arg_count >= 0 and _total_arg_count < args.size():
			args = args.slice(0, _total_arg_count)
		return _callable.callv(args)
	
	func set_priority(priority: Priority) -> ConnectionData:
		_priority = priority
		return self
	
	func set_subpriority(subpriority: int) -> ConnectionData:
		_subpriority = subpriority
		return self
	
	func set_influencing(influencing: bool = true) -> ConnectionData:
		_influencing = influencing
		return self
	
	func set_required_arg_count(arg_count: int) -> ConnectionData:
		_required_arg_count = arg_count
		return self
	
	func set_total_arg_count(arg_count: int) -> ConnectionData:
		_total_arg_count = arg_count
		return self
	
	func is_valid() -> bool:
		return _callable.is_valid()
	
	func get_object() -> Object:
		return _callable.get_object()
