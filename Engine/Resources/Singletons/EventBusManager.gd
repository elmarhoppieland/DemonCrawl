extends Node
class_name EventBusManager

# ==============================================================================
static var _event_owner_list: Dictionary[EventBusManager, Node] = {}
# ==============================================================================
@export var event_owner: Node :
	set(value):
		event_owner = value
		_event_owner_list[self] = value
@export var event_owner_parent: Node :
	set(value):
		_disconnect_event_forwards()
		event_owner_parent = value
		_connect_event_forwards()
# ==============================================================================

func _enter_tree() -> void:
	child_entered_tree.connect(_child_entered_tree)


func _exit_tree() -> void:
	child_entered_tree.disconnect(_child_entered_tree)


func _child_entered_tree(child: Node) -> void:
	if child is not EventBus:
		return
	if event_owner_parent not in _event_owner_list.values():
		return
	
	for manager in _event_owner_list:
		if _event_owner_list[manager] != event_owner_parent:
			continue
		
		var parent_bus: EventBus = null
		for parent_child in manager.get_children():
			if parent_child.get_script() == child.get_script():
				parent_bus = parent_child
				break
		
		if not parent_bus:
			parent_bus = child.get_script().new()
			manager.add_child(parent_bus)
			Debug.log_event("Added EventBus to '%s': %s" % [manager.event_owner.name, UserClassDB.script_get_identifier(child.get_script())])
		
		for s in child.get_script().get_script_signal_list():
			var this_signal := Signal(child, s.name)
			if this_signal.is_null():
				continue
			var parent_signal := Signal(parent_bus, s.name)
			if parent_signal.is_null():
				continue
			this_signal.connect(EffectManager.propagate_forward(parent_signal))


func _connect_event_forwards() -> void:
	if event_owner_parent not in _event_owner_list.values():
		return
	
	for manager in _event_owner_list:
		if _event_owner_list[manager] != event_owner_parent:
			continue
		
		for bus in get_children():
			if bus is not EventBus:
				continue
			
			var parent_bus: EventBus = null
			for child in manager.get_children():
				if child.get_script() == bus.get_script():
					parent_bus = child
					break
			
			if not parent_bus:
				parent_bus = bus.get_script().new()
				manager.add_child(parent_bus)
				Debug.log_event("Added EventBus to '%s': %s" % [manager.event_owner.name, UserClassDB.script_get_identifier(bus.get_script())])
			
			for s in bus.get_signal_list():
				var this_signal := Signal(bus, s.name)
				if this_signal.is_null():
					continue
				var parent_signal := Signal(parent_bus, s.name)
				if parent_signal.is_null():
					continue
				this_signal.connect(EffectManager.propagate_forward(parent_signal))


func _disconnect_event_forwards() -> void:
	if event_owner_parent not in _event_owner_list.values():
		return
	
	for manager in _event_owner_list:
		if _event_owner_list[manager] != event_owner_parent:
			continue
		
		for bus in get_children():
			if bus is not EventBus:
				continue
			
			var parent_bus: EventBus = null
			for child in manager.get_children():
				if child.get_script() == bus.get_script():
					parent_bus = child
					break
			
			if not parent_bus:
				continue
			
			for s in bus.get_signal_list():
				var this_signal := Signal(bus, s.name)
				if this_signal.is_null():
					continue
				var parent_signal := Signal(parent_bus, s.name)
				if parent_signal.is_null():
					continue
				var callable := EffectManager.propagate_forward(parent_signal)
				if this_signal.is_connected(callable):
					this_signal.disconnect(callable)


func get_event_bus(script: Script) -> EventBus:
	for child in get_children():
		if script.instance_has(child):
			return child
	
	var instance: EventBus = script.new()
	add_child(instance)
	Debug.log_event("Added EventBus to '%s': %s" % [event_owner.name, UserClassDB.script_get_identifier(script)])
	return instance
