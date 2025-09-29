@tool
extends RefCounted
class_name AutoThread

# ==============================================================================
var _thread := Thread.new()
var _request_blocker := _RequestBlocker.new()
# ==============================================================================
signal finished(value: Variant)
# ==============================================================================

func get_id() -> String:
	return _thread.get_id()


func is_alive() -> bool:
	return _thread.is_alive()


func is_started() -> bool:
	return _thread.is_started()


func start(callable: Callable, priority: Thread.Priority = Thread.PRIORITY_NORMAL) -> Error:
	if not _request_blocker.available:
		return ERR_BUSY
	
	_request_blocker.raise()
	reference()
	
	var error := _thread.start(callable, priority)
	
	if error == OK:
		(func():
			while _thread.is_alive():
				await Engine.get_main_loop().process_frame
			var value = _thread.wait_to_finish()
			_request_blocker.lower()
			finished.emit(value)
			unreference()
		).call()
	
	return error


func start_when_available(callable: Callable, priority: Thread.Priority = Thread.PRIORITY_NORMAL) -> Error:
	await _request_blocker.wait()
	
	reference()
	
	var error := _thread.start(callable, priority)
	
	if error == OK:
		(func():
			while _thread.is_alive():
				await Engine.get_main_loop().process_frame
			_request_blocker.lower()
			finished.emit(callable)
			unreference()
		).call()
	
	return error


func wait_to_finish() -> Variant:
	return _thread.wait_to_finish()


class _RequestBlocker:
	var available := true
	signal lowered()
	
	func wait() -> void:
		while not available:
			await lowered
		raise()
	
	func raise() -> void:
		available = false
	
	func lower() -> void:
		available = true
		lowered.emit()
