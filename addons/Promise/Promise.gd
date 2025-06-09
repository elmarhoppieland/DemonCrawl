extends RefCounted
class_name Promise

# ==============================================================================
enum Mode {
	LIST,
	MAP
}
# ==============================================================================
var signals: Array[Signal] = []
var signal_map := {}

var mode := Mode.LIST
# ==============================================================================
signal _completed()
# ==============================================================================

func _init(_signals: Variant) -> void:
	assert((_signals is Array and _signals.all(func(a) -> bool: return a is Signal)) or _signals is Dictionary, "Promise only works on an Array of Signals or a Dictionary.")
	
	if _signals is Array:
		signals.assign(_signals)
		mode = Mode.LIST
	else:
		signal_map = _signals
		mode = Mode.MAP


## Returns a [Variant] value after one of the [member signals] has been emitted.
## The returned value is the argument of the [Signal], or [code]null[/code] if the
## [Signal] does not have a parameter.
## [br][br]If this Promise uses a [Signal] map, returns the [Signal]'s value in the
## map instead of the value in the [Signal]'s parameter.
## [br][br]Should be used in combination with [code]await[/code]:
## [codeblock]
## signal signal1()
## signal signal2()
## 
## # code is paused until either signal1 or signal2 is emitted.
## await Promise.new([signal1, signal2]).any()
## [/codeblock]
func any() -> Variant:
	var value := [null]
	for s in _get_signals():
		var lambda := func(argument: Variant = null):
			match mode:
				Mode.LIST:
					value[0] = argument
				Mode.MAP:
					value[0] = signal_map[s]
			
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
	var _signals := _get_signals()
	
	var counter: PackedInt32Array = [_signals.size()]
	var values: Array = []
	for i in _signals.size():
		var s := _signals[i]
		values.append(null)
		s.connect(func(argument: Variant = null):
			match mode:
				Mode.LIST:
					values[i] = argument
				Mode.MAP:
					values[i] = signal_map[s]
			
			counter[0] -= 1
			if counter[0] == 0:
				self._completed.emit()
		, CONNECT_ONE_SHOT)
	
	await _completed
	return values


## [method map] can be used in two ways:
## [br][br]If this is a mapping Promise, maps any number of [Signal]s to a [Callable]
## each. The next time one of the [Signal]s is emitted, calls the [Callable] mapped
## to that [Signal].
## [br][br]If this is a listing Promise, when any number of the provided [Signal]s
## is emitted, returns the [Signal].
## [br][br][b]Note:[/b] For mapping mode: Only calls the mapped [Callable] for the
## first [Signal] that is emitted. To wait for all [Signal]s, use all() and iterate
## over the returned [Array].
## [br][br][b]Note:[/b] If this is a mapping Promise, this is equivalent to calling
## [code](await any()).call()[/code].
func map() -> Variant:
	if mode == Mode.LIST:
		var _signal_map := {}
		for s in _get_signals():
			_signal_map[s] = s
		return await Promise.new(_signal_map).any()
	
	return (await any()).call()


func _get_signals() -> Array[Signal]:
	match mode:
		Mode.LIST:
			return signals
		Mode.MAP:
			var _signals: Array[Signal] = []
			_signals.assign(signal_map.keys())
			return _signals
	
	assert(false, "Invalid mode on Promise instance.")
	return []


static func capture(s: Signal) -> Variant:
	var value := [null]
	s.connect(func(arg: Variant = null): value[0] = arg, CONNECT_ONE_SHOT)
	await s
	return value[0]


static func defer() -> void:
	var s := _temp_signal()
	(func() -> void:
		s.emit()
	).call_deferred()
	await s


static func signal_await(await_callable: Callable) -> Signal:
	var s := _temp_signal()
	(func() -> void:
		s.emit(await await_callable.call())
	).call()
	return s


static func _temp_signal() -> Signal:
	var obj := Object.new()
	obj.add_user_signal("_tmp")
	var s := Signal(obj, "_tmp")
	s.connect(func() -> void: obj.free(), CONNECT_DEFERRED)
	return s


static func dynamic_signal(owner_callable: Callable, signal_name: String, changed_signal: Signal) -> Signal:
	var obj := _SignalObject.new()
	
	(func() -> void:
		var emitter := func(arg0: Variant = obj, arg1: Variant = obj, arg2: Variant = obj, arg3: Variant = obj, arg4: Variant = obj, arg5: Variant = obj, arg6: Variant = obj, arg7: Variant = obj, arg8: Variant = obj, arg9: Variant = obj) -> void:
			var args := [arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9]
			var call_args := ["s"]
			for arg in args:
				if arg == obj:
					break
				call_args.append(arg)
			obj.emit_signal.callv(call_args)
		
		var owner: Variant
		var owner_signal := Signal()
		var ready := false
		while true:
			if ready and obj.s.get_connections().is_empty():
				break
			
			if not owner_signal.is_null():
				owner_signal.disconnect(emitter)
			
			owner = owner_callable.call()
			ready = true
			
			if owner == null:
				owner_signal = Signal()
				await changed_signal
				continue
			
			assert(owner is Object, "The provided callable must return an Object.")
			assert(signal_name in owner, "The returned owner must have a property named '%s'." % signal_name)
			assert(owner.get(signal_name) is Signal, "The returned owner's property must be of type Signal.")
			
			owner_signal = owner.get(signal_name)
			owner_signal.connect(emitter)
			
			await changed_signal
	).call()
	
	return obj.s


class _SignalObject:
	signal s()
