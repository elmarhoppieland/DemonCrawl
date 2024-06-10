extends RefCounted
class_name Promise

# ==============================================================================
var signals: Array[Signal]
var mapped_callables: Array[Callable] = []
# ==============================================================================
signal _completed()
# ==============================================================================

func _init(_signals: Array[Signal], _callables: Array[Callable] = []) -> void:
	signals = _signals
	mapped_callables = _callables


## Returns a [Variant] value after one of the given [member signals] has been emitted.
## The returned value is the argument of the [Signal], or [code]null[/code] if the
## [Signal] does not have a parameter.
## [br][br]Should be used in combination with [code]await[/code]:
## [codeblock]
## signal signal1()
## signal signal2()
## 
## # code is paused until either signal1 or signal2 is emitted.
## await Promise.any([signal1, signal2])
## [/codeblock]
func any() -> Variant:
	var value := [null]
	for s in signals:
		var lambda := func(argument: Variant = null):
			value[0] = argument
			self._completed.emit()
		s.connect(lambda)
		self._completed.connect(func(): s.disconnect(lambda), CONNECT_ONE_SHOT)
	
	await _completed
	return value[0]


## Returns an [Array] of [Variant] values after all of the given [member signals]
## have been emitted. Each of the returned [Array]'s elements are arguments of the [Signal]s,
## or [code]null[/code] if the [Signal] does not have an argument.
## [br][br]Should be used in combination with [code]await[/code]:
## [codeblock]
## signal signal1()
## signal signal2()
## 
## # code is paused until both signal1 and signal2 are emitted.
## await Promise.all([signal1, signal2])
## [/codeblock]
func all() -> Array[Variant]:
	var counter: PackedInt32Array = [signals.size()]
	var values: Array = []
	for i in signals.size():
		var s := signals[i]
		values.append(null)
		s.connect(func(argument: Variant = null):
			values[i] = argument
			counter[0] += 1
			if counter[0] == 0:
				self._completed.emit()
		, CONNECT_ONE_SHOT)
	
	await _completed
	return values


## Maps any number of [Signal]s to a [Callable] each. The next time one of the
## [Signal]s is emitted, calls the [Callable] mapped to that [Signal].
## [br][br]See also [method map_await].
## [br][br][b]Note:[/b] Only calls the mapped [Callable] for the first [Signal]
## that is emitted.
func map(signal_map: Dictionary) -> Variant:
	var value := [null]
	for s: Signal in signal_map:
		var lambda := func():
			value[0] = signal_map[s].call()
			self._completed.emit()
		
		s.connect(lambda)
		
		_completed.connect(func():
			s.disconnect(lambda)
		, CONNECT_ONE_SHOT)
	
	await _completed
	return value[0]


## Maps any number of [Signal]s to a [Callable] each. The next time one of the
## [Signal]s is emitted, calls the [Callable] mapped to that [Signal] and [code]await[/code]s it.
## [br][br]See also [method map].
## [br][br][b]Note:[/b] Only calls the mapped [Callable] for the first [Signal]
## that is emitted.
func map_await(signal_map: Dictionary) -> Variant:
	var value := [null]
	for s: Signal in signal_map:
		var lambda := func():
			value[0] = await signal_map[s].call()
			self._completed.emit()
		
		s.connect(lambda)
		
		_completed.connect(func():
			s.disconnect(lambda)
		, CONNECT_ONE_SHOT)
	
	await _completed
	return value[0]


static func get_arg(s: Signal) -> Variant:
	var value := [null]
	s.connect(func(arg: Variant = null): value[0] = arg, CONNECT_ONE_SHOT)
	await s
	return value[0]
