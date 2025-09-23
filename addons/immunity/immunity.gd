@abstract
class_name Immunity

# ==============================================================================

static func create_immunity_list() -> ImmunityList:
	return ImmunityList.new()


class ImmunityList:
	var _blockers: Dictionary[String, Dictionary] = {}
	var _forwarded_immunities: Array[ImmunityList] = []
	
	func try_call(callable: Callable, name: StringName = &"") -> Variant:
		if can_call(callable, name):
			return callable.call()
		return null
	
	
	func can_call(callable: Callable, name: StringName = &"") -> bool:
		if name.is_empty():
			name = callable.get_method()
		
		for immunity in _forwarded_immunities:
			if not immunity.can_call(callable, name):
				return false
		
		if name not in _blockers:
			return true
		
		var object := callable.get_object()
		var script := object if object is Script else (object.get_script() as Script)
		
		var base := script
		while base != null:
			for blocker in _get_blockers(name, base):
				if not blocker.call(callable):
					return false
			base = base.get_base_script()
		
		return true
	
	
	func add_blocker(type_script: Script, name: StringName, blocker: Callable) -> void:
		if name not in _blockers:
			_blockers[name] = {}
		if type_script not in _blockers[name]:
			_blockers[name][type_script] = [] as Array[Callable]
		
		var blockers: Array[Callable] = _blockers[name][type_script]
		if blocker not in blockers:
			blockers.append(blocker)
	
	
	func remove_blocker(type_script: Script, name: StringName, blocker: Callable) -> void:
		if name not in _blockers:
			return
		if type_script not in _blockers[name]:
			return
		
		var blockers: Array[Callable] = _blockers[name][type_script]
		if blocker in blockers:
			blockers.erase(blocker)
	
	
	func add_forwarded_immunity(forward_blocker: ImmunityList) -> void:
		_forwarded_immunities.append(forward_blocker)
	
	
	func remove_forwarded_immunity(forward_blocker: ImmunityList) -> void:
		_forwarded_immunities.erase(forward_blocker)
	
	
	func _get_blockers(name: String, base: Script) -> Array[Callable]:
		var blockers := _blockers[name]
		
		if base not in blockers:
			return []
		
		var invalid_blockers := PackedInt32Array()
		for i in blockers[base].size():
			if not blockers[base][i].is_valid():
				invalid_blockers.append(i)
		
		for i in invalid_blockers.size():
			blockers[base].remove_at(invalid_blockers[i] - i)
		
		return blockers[base]
