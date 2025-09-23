extends Node
class_name ActionManager

# ==============================================================================
var _registered_callables: Array[Callable] = []
var _registered_release_callables: Array[Callable] = []
# ==============================================================================

## Registers a [Callable]. The given [param callable] should take in an [Object]
## argument, and return either a [Callable] or an [Array] of [Callable]s.
func register(callable: Callable) -> void:
	_register(callable, _registered_callables)


## Unregisters a [Callable].
func unregister(callable: Callable) -> void:
	_unregister(callable, _registered_callables)


## Registers a [Callable] for release actions.  The given [param callable] should
## take in an [Object] argument, and return either a [Callable] or an [Array] of
## [Callable]s.
func register_release(callable: Callable) -> void:
	_register(callable, _registered_release_callables)


## Unregisters a [Callable] for release actions.
func unregister_release(callable: Callable) -> void:
	_unregister(callable, _registered_release_callables)


func _register(callable: Callable, list: Array[Callable]) -> void:
	if callable.get_argument_count() == 0:
		Debug.log_error("Cannot register callable '%s': Expected 1 argument, found 0." % callable)
		return
	list.append(callable)


func _unregister(callable: Callable, list: Array[Callable]) -> void:
	list.erase(callable)


## Returns all available actions for the given [param object].
func get_actions(object: Object) -> Array[Callable]:
	return _get_actions(object, _registered_callables)


## Returns all available release actions for the given [param object].
func get_release_actions(object: Object) -> Array[Callable]:
	return _get_actions(object, _registered_release_callables)


func _get_actions(object: Object, registered_callables: Array[Callable]) -> Array[Callable]:
	_validate_registered_callables(registered_callables)
	
	var actions: Array[Callable] = []
	var tree := EffectManager.get_priority_tree()
	
	var queue: Array[EffectManager.PriorityNode] = [tree.root]
	var handled_callables: Array[Callable] = []
	
	while not queue.is_empty():
		var node := queue.pop_front() as EffectManager.PriorityNode
		for callable in registered_callables:
			if callable in handled_callables:
				continue
			if node.handles(callable):
				var value = callable.call(object)
				
				if value is Callable:
					actions.append(value)
				elif value is Array:
					actions.append_array(value)
				else:
					Debug.log_error("Registered action callable did not return a valid type. Expected a value of type Callable or Array, but found '%s'." % type_string(typeof(value)))
				
				handled_callables.append(callable)
		
		queue.append_array(node.get_children())
	
	for callable in registered_callables:
		if callable in handled_callables:
			continue
		
		var value = callable.call(object)
		if value is Callable:
			actions.append(value)
		elif value is Array:
			actions.append_array(value)
		else:
			Debug.log_error("Registered action callable did not return a valid type. Expected a value of type Callable or Array, but found '%s'." % type_string(typeof(value)))
		
		handled_callables.append(callable)
	
	return actions


func _validate_registered_callables(registered_callables: Array[Callable]) -> void:
	var invalid_count := 0
	for i in registered_callables.size():
		if not registered_callables[i - invalid_count].is_valid():
			registered_callables.remove_at(i - invalid_count)
			invalid_count += 1
