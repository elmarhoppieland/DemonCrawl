extends StaticClass
class_name EffectManager

# ==============================================================================
static var objects: Array[Object] = []
# ==============================================================================

static func register_object(object: Object, allow_duplicates: bool = false) -> void:
	if not object in objects or allow_duplicates:
		objects.append(object)


static func change_stat(stat: StringName, value: Variant) -> Variant:
	return propagate_value(&"change_" + stat, [], value)


static func propagate_call(method_name: StringName, args: Array = []) -> void:
	for object in objects:
		if not object.has_method(method_name):
			continue
		
		object.callv(method_name, args)


static func propagate_value(method_name: StringName, args: Array, initial_value: Variant, force_same_type: bool = true) -> Variant:
	args.append(initial_value)
	
	for object in objects:
		if not object.has_method(method_name):
			continue
		
		var returned = object.callv(method_name, args)
		if returned == null:
			continue
		if force_same_type and typeof(returned) != typeof(initial_value):
			Debug.log_error("Method '%s' on object '%s' returned an incorrect value type. Should be '%s', but '%s' was returned." % [method_name, object, type_string(typeof(initial_value)), type_string(typeof(returned))])
			continue
		
		args[-1] = returned
	
	return args.pop_back()


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
