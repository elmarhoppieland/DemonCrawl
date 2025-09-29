extends Object
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
static var _priority_tree: PriorityTree

static var _initialized := false
# ==============================================================================

static func _initialize() -> void:
	var inheriters := UserClassDB.get_inheriters_from_class(&"EffectScript")
	for i in inheriters.size():
		var name := inheriters[i]
		register_object(UserClassDB.instantiate(name), i)
	
	_initialized = true


## Registers [param object]. Future calls to [method propagate_call],
## [method propagate_value] or [method propagate_posnum] will be passed into the
## given object.
## [br][br]The order in which effects are propagated depend on the object's
## [param priority] and [param subpriority] arguments. The object's
## [param priority] specifies what group this object belong to, as a value
## of the [enum Priority] enum. The object's [param subpriority] further specifies
## the order in which objects of the same group (priority) are called. These arguments
## should always be consistent so behaviour is deterministic.
## [br][br]If [param allow_duplicates] is [code]false[/code], the object
## will not be registered if it has already been registered. If [param allow_duplicates]
## is [code]true[/code] and the object was already registered, propagating calls
## will be passed into the object once for each time it has been registered.
## This can be useful to allow objects to trigger an extra time.
## [br][br][b]Note:[/b] This method registers all methods on the given object.
## To register only one specific [Callable], use [method connect_effect].
static func register_object(object: Object, connect_flags: int = 0) -> void:
	for method in UserClassDB.class_get_method_list(UserClassDB.script_get_identifier(object.get_script())):
		if method.return.type == TYPE_NIL:
			if method.name in Effects.Signals:
				Effects.Signals[method.name].connect(object[method.name], connect_flags)
		else:
			if method.name in Effects.MutableSignals:
				Effects.MutableSignals[method.name].connect(object[method.name], connect_flags)


## Unregisters [param object]. Future calls to [method propagate_call],
## [method propagate_value] or [method propagate_posnum] will no longer be passed
## into the given object.
## [br][br]If the object was registered multiple times, it will only be unregistered
## once. Future propagations will only be passed one fewer time for each time
## the object gets unregistered.
static func unregister_object(object: Object) -> void:
	for method in UserClassDB.class_get_method_list(UserClassDB.script_get_identifier(object.get_script())):
		var name: String = method.name
		if name not in Effects.Signals:
			continue
		if method.return.type == TYPE_NIL:
			Effects.Signals[name].disconnect(object[name])
		else:
			Effects.MutableSignals[name].disconnect(object[name])


## Propagates the given [param effect], calling all [Callable]s that are connected
## to the [Signal] in the order that the priority groups give. An [Array] of arguments
## can optionally be passed into each [Callable].
static func propagate(effect: Signal, ...args: Array) -> void:
	_propagate.callv([effect, -1] + args)


## Propagates the given [param effect], calling all [Callable]s that are connected
## to the [Signal] in the order that the priority groups give. An [Array] of arguments
## can optionally be passed into each [Callable]. The return value of each [Callable]
## will replace the value at the index the value of [param mutable] specifies.
static func propagate_mutable(effect: Signal, mutable: int, ...args: Array) -> Variant:
	assert(mutable >= 0, "Cannot mutate from a negative index.")
	assert(args.size() > mutable, "Cannot use the mutable index since not enough arguments were provided.")
	
	return _propagate.callv([effect, mutable] + args)


static func _propagate(effect: Signal, mutable: int, ...args: Array) -> Variant:
	var connections: Array[Dictionary] = []
	connections.assign(effect.get_connections())
	args = args.duplicate()
	if not connections.is_empty():
		var previous_mutable := get_priority_tree().current_mutable
		var previous_args := get_priority_tree().current_args
		get_priority_tree().current_mutable = mutable
		get_priority_tree().current_args = args
		
		get_priority_tree().root.propagate(connections)
		
		get_priority_tree().current_mutable = previous_mutable
		get_priority_tree().current_args = previous_args
	
	return null if mutable < 0 else args[mutable]


static func propagate_forward(effect: Signal) -> Callable:
	var object := effect.get_object()
	var arg_count := -1
	for s in object.get_signal_list():
		if s.name == effect.get_name():
			arg_count = s.args.size()
			break
	assert(arg_count >= 0, "Could not find the effect signal on its object.")
	
	var callable := func propagate_forward_lambda() -> Variant:
		return _propagate.callv([effect, get_priority_tree().current_mutable] + get_priority_tree().current_args)
	if arg_count > 0:
		callable = callable.unbind(arg_count)
	return callable


## Returns the priority tree. This is a [SceneTree]-like object that holds priority
## nodes. Each priority node determines the order [Callable]s are called in
## [method propagate].
## [br][br][b]Note:[/b] Changing anything in the priority tree may not work as expected.
## Only use this method if you know what you are doing.
static func get_priority_tree() -> PriorityTree:
	if not _priority_tree:
		_priority_tree = PriorityTree.new()
	return _priority_tree


## Reloads the priority tree from the file stored in the filesystem.
static func reload_priority_tree() -> void:
	_priority_tree = PriorityTree.new()


class PriorityTree:
	var root := PriorityRoot.new()
	var interrupted := false
	var current_mutable := -1
	var current_args := []
	
	func _init() -> void:
		root._tree = weakref(self)
	
	func interrupt() -> void:
		interrupted = true


class PriorityNode:
	var name := ""
	var _parent: WeakRef = null
	var _tree: WeakRef = null
	
	func propagate(connections: Array[Dictionary]) -> Array[Dictionary]:
		var unhandled_connections: Array[Dictionary] = []
		
		for connection in connections:
			if get_tree().current_args.size() > connection.callable.get_argument_count():
				Debug.log_error("Too many arguments provided. Expected at most %d, but received %d." % [connection.callable.get_argument_count(), get_tree().current_args.size()])
				continue
			
			if get_tree().interrupted:
				get_tree().interrupted = false
				return []
			
			if handles(connection.callable):
				if get_tree().current_mutable < 0:
					connection.callable.callv(get_tree().current_args)
				else:
					get_tree().current_args[get_tree().current_mutable] = connection.callable.callv(get_tree().current_args)
				
				if connection.flags & CONNECT_ONE_SHOT:
					connections.erase(connection)
			else:
				unhandled_connections.append(connection)
		
		for child in get_children():
			unhandled_connections = child.propagate(unhandled_connections)
		
		return unhandled_connections
	
	func handles(callable: Callable) -> bool:
		return _handles(callable)
	
	@warning_ignore("unused_parameter")
	func _handles(callable: Callable) -> bool:
		return false
	
	func has_children() -> bool:
		return false
	
	func get_children() -> Array[PriorityNode]:
		return []
	
	func can_have_children() -> bool:
		return false
	
	func is_editable() -> bool:
		return false
	
	func get_icon() -> Texture2D:
		return null
	
	func get_parent() -> PriorityNode:
		if _parent != null:
			return _parent.get_ref()
		return null
	
	func set_parent(parent: PriorityNode) -> void:
		_parent = weakref(parent)
	
	func get_tree() -> PriorityTree:
		return _tree.get_ref() if _tree else null
	
	func add_child(child: PriorityNode) -> void:
		assert(can_have_children(), "add_child() can only be used on a node that can have children.")
		assert(child.get_parent() == null, "Cannot add a child that already has a parent.")
		
		child._parent = weakref(self)
		child._tree = _tree
		get_children().append(child)
	
	func insert_child(child: PriorityNode, index: int) -> void:
		assert(can_have_children(), "add_child() can only be used on a node that can have children.")
		assert(child.get_parent() == null, "Cannot add a child that already has a parent.")
		
		child._parent = weakref(self)
		get_children().insert(index, child)
	
	func remove_child(child: PriorityNode) -> void:
		assert(can_have_children(), "remove_child() can only be used on a node that can have children.")
		assert(child in get_children(), "Cannot remove a child from a node that is not its parent.")
		
		child._parent = null
		get_children().erase(child)
	
	func pack() -> String:
		var string := UserClassDB.script_get_class(get_script()).trim_prefix("EffectManager:") + ":" + name
		
		var extra_data := _pack()
		if not extra_data.is_empty():
			string += "\n-" + "\n-".join(extra_data)
		
		if has_children():
			for child in get_children():
				string += "\n" + "\n".join(Array(child.pack().split("\n")).map(func(s: String) -> String: return "\t" + s))
		
		return string.strip_edges()
	
	func _pack() -> PackedStringArray:
		return []
	
	static func unpack(string: String) -> PriorityNode:
		assert(":" in string.get_slice("\n", 0), "The priority node's first line must contain the node's class name.")
		
		if not UserClassDB.class_exists("EffectManager::" + string.get_slice("::", 0)):
			push_error("Class '%s' does not exist." % ("EffectManager::" + string.get_slice("::", 0)))
			return null
		
		var node: PriorityNode = UserClassDB.instantiate("EffectManager::" + string.get_slice("::", 0))
		node.name = string.get_slice("\n", 0).get_slice(":", 1)
		
		var data := PackedStringArray()
		for line in string.split("\n").slice(1):
			match line[0]:
				"-":
					data.append(line.trim_prefix("-"))
				"\t":
					break
				_:
					assert(false, "The priority node has an invalid line '%s': The first character must be a '-' or a tab." % line)
		
		node._unpack(data)
		
		if node.can_have_children():
			var children_data := PackedStringArray()
			for line in string.split("\n").slice(1 + data.size()):
				match line[1]:
					"\t", "-":
						children_data[-1] += line.trim_prefix("\t") + "\n"
					_:
						children_data.append(line.trim_prefix("\t") + "\n")
			
			for child_data in children_data:
				var child := PriorityNode.unpack(child_data.strip_edges())
				node.add_child(child)
		
		return node
	
	func _unpack(_data: PackedStringArray) -> void:
		pass


class PriorityGroup extends PriorityNode:
	enum Type {
		SCRIPT_INSTANCES,
		NODE_CHILDREN,
		SCRIPT_SINGLETON
	}
	
	var type := Type.SCRIPT_INSTANCES
	var data := ""
	
	func _handles(callable: Callable) -> bool:
		match type:
			Type.SCRIPT_INSTANCES:
				var script := UserClassDB.class_get_script(data)
				if not script:
					return false
				
				var object := callable.get_object()
				if callable.is_custom() and script == object:
					# this is probably a lambda function on the class
					# we are allowing this since instances can also create these
					return true
				
				return script.instance_has(object)
			Type.NODE_CHILDREN:
				var object := callable.get_object()
				return object is Node and (object as Node).get_node(data).is_ancestor_of(object)
			Type.SCRIPT_SINGLETON:
				return callable.get_object() == UserClassDB.class_get_script(data)
		
		return false
	
	func is_editable() -> bool:
		return true
	
	func get_icon() -> Texture2D:
		match type:
			Type.SCRIPT_INSTANCES:
				return preload("res://addons/effect_manager/script.png")
			Type.NODE_CHILDREN:
				return preload("res://addons/effect_manager/node.png")
			Type.SCRIPT_SINGLETON:
				return preload("res://addons/effect_manager/gd_script.png")
		
		return super()
	
	func _pack() -> PackedStringArray:
		return ["type: " + str(type), "data: " + data]
	
	func _unpack(strings: PackedStringArray) -> void:
		var dict := {}
		for string in strings:
			dict[string.substr(0, string.find(":"))] = string.substr(string.find(":") + 2)
		
		type = dict.type.to_int() as Type
		data = dict.data


class PrioritySection extends PriorityNode:
	var _children: Array[PriorityNode] = [] : get = get_children
	
	func get_children() -> Array[PriorityNode]:
		return _children
	
	func has_children() -> bool:
		return not _children.is_empty()
	
	func can_have_children() -> bool:
		return true
	
	func get_icon() -> Texture2D:
		return preload("res://addons/effect_manager/folder.png")


class PriorityRoot extends PrioritySection:
	func _init() -> void:
		if not FileAccess.file_exists("res://.data/effect_manager/priority_groups.txt"):
			FileAccess.open("res://.data/effect_manager/priority_groups.txt", FileAccess.WRITE)
			return
		
		var file := FileAccess.open("res://.data/effect_manager/priority_groups.txt", FileAccess.READ)
		if not file:
			push_error("Could not open file 'res://.data/effect_manager/priority_groups.txt': ", error_string(FileAccess.get_open_error()))
			return
		
		var node_string := file.get_line() + "\n"
		while true:
			var line := file.get_line()
			if line.is_empty():
				add_child(PriorityNode.unpack(node_string.strip_edges()))
				break
			if not line.begins_with("-") and not line.begins_with("\t"):
				add_child(PriorityNode.unpack(node_string.strip_edges()))
				node_string = ""
			
			node_string += line + "\n"
	
	func pack() -> String:
		var string := ""
		
		for child in get_children():
			string += child.pack() + "\n"
		
		return string.strip_edges()
	
	func propagate(connections: Array[Dictionary]) -> Array[Dictionary]:
		for child in get_children():
			connections = child.propagate(connections)
		
		for connection in connections:
			if get_tree().current_args.size() > connection.callable.get_argument_count():
				Debug.log_error("Too many arguments provided. Expected at most %d, but received %d." % [connection.callable.get_argument_count(), get_tree().current_args.size()])
				continue
			
			if get_tree().current_mutable < 0:
				connection.callable.callv(get_tree().current_args)
			else:
				get_tree().current_args[get_tree().current_mutable] = connection.callable.callv(get_tree().current_args)
			
			if connection.flags & CONNECT_ONE_SHOT:
				connections.erase(connection)
		
		get_tree().interrupted = false
		return connections
