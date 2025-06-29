extends StaticClass
class_name Immunity

# ==============================================================================
static var _blockers := {}
# ==============================================================================

static func try_call(callable: Callable, name: StringName = &"") -> Variant:
	if name.is_empty():
		name = callable.get_method()
	if name not in _blockers:
		return callable.call()
	
	var object := callable.get_object()
	var script := object if object is Script else (object.get_script() as Script)
	
	var base := script
	while base != null:
		for blocker in _get_blockers(name, base):
			if not blocker.call(callable):
				return null
		base = base.get_base_script()
	
	return callable.call()


static func add_blocker(type_script: Script, name: StringName, blocker: Callable) -> void:
	if name not in _blockers:
		_blockers[name] = {}
	if type_script not in _blockers[name]:
		_blockers[name][type_script] = [] as Array[Callable]
	
	var blockers: Array[Callable] = _blockers[name][type_script]
	if blocker not in blockers:
		blockers.append(blocker)


static func remove_blocker(type_script: Script, name: StringName, blocker: Callable) -> void:
	if name not in _blockers:
		return
	if type_script not in _blockers[name]:
		return
	
	var blockers: Array[Callable] = _blockers[name][type_script]
	if blocker in blockers:
		blockers.erase(blocker)


static func _get_blockers(name: String, base: Script) -> Array[Callable]:
	var blockers: Dictionary = _blockers[name]
	
	if base not in blockers:
		return []
	
	var invalid_blockers := PackedInt32Array()
	for i in blockers[base].size():
		if not blockers[base][i].is_valid():
			invalid_blockers.append(i)
	
	for i in invalid_blockers.size():
		blockers[base].remove_at(invalid_blockers[i] - i)
	
	return blockers[base]
