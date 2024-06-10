extends Object
class_name EventBus

# ==============================================================================
static var events: Array[Event] = []
# ==============================================================================

static func connect_event(event_name: StringName, callable: Callable, flags: int = 0) -> void:
	_get_event(event_name, true).add_connection(callable, flags)


static func emit_event(event_name: StringName, args: Array = []) -> void:
	_get_event(event_name, true).emit(args)


static func disconnect_event(event_name: StringName, callable: Callable) -> void:
	var event := _get_event(event_name, false)
	if not event:
		return
	
	event.remove_connection(callable)


static func get_event_signal(event_name: StringName) -> Signal:
	return _get_event(event_name, true).emitted


static func is_event_connected(event_name: StringName, callable: Callable) -> bool:
	var event := _get_event(event_name, false)
	return event and event.has_connection(callable)


static func event_exists(event_name: StringName) -> bool:
	for event in events:
		if event.name == event_name:
			return true
	return false


static func _get_event(event_name: StringName, allow_creating: bool) -> Event:
	for event in events:
		if event.name == event_name:
			return event
	
	if not allow_creating:
		return null
	
	var event := Event.new()
	event.name = event_name
	return event


class Connection:
	var callable := Callable()
	var flags := 0
	var ref_count := 0 :
		get:
			if flags & CONNECT_REFERENCE_COUNTED:
				return ref_count
			return -1
	
	func call_method(args: Array = []) -> void:
		if flags & CONNECT_DEFERRED:
			(func(): callable.callv(args)).call_deferred()
		else:
			callable.callv(args)


class Event:
	var name := &""
	var connections: Array[Connection] = []
	
	signal emitted(args: Array)
	
	func emit(args: Array = []) -> void:
		for connection in connections:
			connection.call_method(args)
		emitted.emit(args)
	
	func add_connection(callable: Callable, flags: int = 0) -> void:
		if has_connection(callable) and not flags & CONNECT_REFERENCE_COUNTED:
			return
		
		var connection := Connection.new()
		connection.callable = callable
		connection.flags = flags
		
		connections.append(connection)
	
	func remove_connection(callable: Callable) -> void:
		for connection in connections:
			if connection.callable != callable:
				continue
			
			if connection.flags & CONNECT_REFERENCE_COUNTED:
				connection.ref_count -= 1
				if connection.ref_count > 0:
					return
			
			connections.erase(connection)
	
	func has_connection(callable: Callable) -> bool:
		for connection in connections:
			if connection.callable == callable:
				return true
		
		return false


class EventWaiter:
	var event_name := &""
	
	func _init(_event_name: StringName) -> void:
		event_name = _event_name
	
	func wait() -> void:
		var event := EventBus._get_event(event_name, false)
		await event.emitted
