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
static var objects: Array[Object] = [] :
	get:
		if not _initialized:
			_initialized = true
			_initialize.call_deferred()
		return objects
# ==============================================================================
static var _initialized := false
# ==============================================================================

static func _initialize() -> void:
	if OS.is_debug_build():
		_register_directory("res://", FileAccess.open("res://.data/EffectManager.files", FileAccess.WRITE))
	else:
		var file := FileAccess.open("res://.data/EffectManager.files", FileAccess.READ)
		while not file.eof_reached():
			var path := file.get_line()
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
	if Engine.is_editor_hint():
		return
	
	for object in objects.duplicate():
		if not object.has_method(method_name):
			continue
		
		object.callv(method_name, args)
	
	_Instance.called.emit(method_name, args)


static func propagate_value(method_name: StringName, args: Array, initial_value: Variant, forced_type: Variant.Type = typeof(initial_value) as Variant.Type) -> Variant:
	if Engine.is_editor_hint():
		return initial_value
	
	args.push_front(initial_value)
	
	var effect_objects := objects.filter(func(o: Object): return o.has_method(method_name))
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
	
	for object in reactive_objects:
		object.callv(method_name, args)
	
	_Instance.called.emit(method_name, args)
	
	return args.pop_front()


static func propagate_posnum(method_name: StringName, args: Array, initial_value: Variant, forced_type: Variant.Type = typeof(initial_value) as Variant.Type) -> Variant:
	return maxi(0, propagate_value(method_name, args, initial_value, forced_type))


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
