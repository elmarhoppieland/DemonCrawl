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
	var obj := RefCounted.new()
	obj.add_user_signal("_tmp")
	(func():
		obj.emit_signal("_tmp")
	).call_deferred()
	await Signal(obj, "_tmp")
