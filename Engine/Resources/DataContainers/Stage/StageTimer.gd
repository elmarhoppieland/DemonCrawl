@tool
extends Node
class_name StageTimer

# ==============================================================================
const _TIME_SECOND_FACTOR := 1e-6
# ==============================================================================
var _paused := false

var _time_usec := 0 :
	set(value):
		var old := _time_usec
		_time_usec = value
		
		for i in int(value * _TIME_SECOND_FACTOR) - int(old * _TIME_SECOND_FACTOR):
			second_passed.emit()
var _last_read_time_usec := Time.get_ticks_usec()

var _blockers: Array[WeakRef] = [] :
	get:
		var invalid := PackedInt32Array()
		for i in _blockers.size():
			if _blockers[i].get_ref() == null:
				invalid.append(i)
		
		for i in invalid.size():
			_blockers.remove_at(invalid[i] - i)
		
		return _blockers
# ==============================================================================
signal second_passed()
# ==============================================================================

func _process(_delta: float) -> void:
	var curr_usec := Time.get_ticks_usec()
	if not is_paused():
		_time_usec += curr_usec - _last_read_time_usec
	_last_read_time_usec = curr_usec


func get_timef() -> float:
	return _time_usec * _TIME_SECOND_FACTOR


func get_time() -> int:
	return int(get_timef())


func pause() -> void:
	_paused = true


func play() -> void:
	_paused = false


func block(blocker: Object) -> void:
	_blockers.append(weakref(blocker))


func unblock(blocker: Object) -> void:
	for i in _blockers.size():
		if _blockers[i].get_ref() == blocker:
			_blockers.remove_at(i)
			break


func is_paused() -> bool:
	return _paused or not _blockers.is_empty() or get_tree().paused


func create_subtimer() -> SubTimer:
	return SubTimer.new(self)


func _process_subtimer(subtimer: WeakRef) -> void:
	var timer := subtimer.get_ref() as SubTimer
	if not timer:
		return


func _export_packed() -> float:
	return get_timef()


static func _import_packed(time: float) -> StageTimer:
	var timer := StageTimer.new()
	timer._time = time
	return timer


class SubTimer:
	var _timer: StageTimer
	var _start_time: float
	var _previous_time: float
	
	func _init(timer: StageTimer) -> void:
		_timer = timer
		_start_time = timer.get_timef()
		_previous_time = timer.get_timef()
		
		timer.get_tree().process_frame.connect(func() -> void:
			for i in int(timer.get_timef() - _start_time) - int(_previous_time - _start_time):
				second_passed.emit()
			_previous_time = timer.get_timef()
		)
	
	signal second_passed()
