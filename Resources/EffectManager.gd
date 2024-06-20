extends StaticClass
class_name EffectManager

# ==============================================================================
static var objects: Array[Object] = []
# ==============================================================================

static func register_object(object: Object, allow_duplicates: bool = false) -> void:
	if not object in objects or allow_duplicates:
		objects.append(object)
	
	if object is Node:
		object.tree_exited.connect(unregister_object.bind(object), CONNECT_ONE_SHOT)


static func unregister_object(object: Object) -> void:
	objects.erase(object)


static func change_stat(stat: StringName, value: Variant) -> Variant:
	return propagate_value(&"change_" + stat, [], value)


static func propagate_call(method_name: StringName, args: Array = []) -> void:
	_Instance.called.emit(method_name, args)
	
	for object in objects:
		if not object.has_method(method_name):
			continue
		
		object.callv(method_name, args)


static func propagate_value(method_name: StringName, args: Array, initial_value: Variant, force_same_type: bool = true) -> Variant:
	args.push_front(initial_value)
	
	for object in objects:
		if not object.has_method(method_name):
			continue
		
		var returned = object.callv(method_name, args)
		if returned == null:
			continue
		if force_same_type and typeof(returned) != typeof(initial_value):
			Debug.log_error("Method '%s' on object '%s' returned an incorrect value type. Should be '%s', but '%s' was returned." % [method_name, object, type_string(typeof(initial_value)), type_string(typeof(returned))])
			continue
		
		args[0] = returned
	
	return args.pop_front()


static func propagate_posnum(method_name: StringName, args: Array, initial_value: Variant, force_same_type: bool = true) -> Variant:
	args.push_front(initial_value)
	
	for object in objects:
		if not object.has_method(method_name):
			continue
		
		var returned = object.callv(method_name, args)
		if returned == null:
			continue
		if force_same_type and typeof(returned) != typeof(initial_value):
			Debug.log_error("Method '%s' on object '%s' returned an incorrect value type. Should be '%s', but '%s' was returned." % [method_name, object, type_string(typeof(initial_value)), type_string(typeof(returned))])
			continue
		
		args[0] = returned
		
		if args[0] <= 0:
			break
	
	return maxi(args.pop_front(), 0)


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


class _Instance:
	static var _instance := _Instance.new()
	static var called: Signal :
		get:
			return _instance._called
	signal _called(method_name: StringName, args: Array)
