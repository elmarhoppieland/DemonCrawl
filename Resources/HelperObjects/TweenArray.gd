@tool
extends RefCounted
class_name TweenArray

# ==============================================================================
var _tweens: Array[Tween] = []
# ==============================================================================

func bind_node(node: Node) -> TweenArray:
	for tween in _tweens:
		tween.bind_node(node)
	return self


func chain() -> TweenArray:
	for tween in _tweens:
		tween.chain()
	return self


func custom_step(delta: float) -> bool:
	var running := false
	for tween in _tweens:
		var r := tween.custom_step(delta)
		if r:
			running = true
	return running


func get_loops_left() -> int:
	var loops := 0
	for tween in _tweens:
		if tween.get_loops_left() > loops:
			loops = tween.get_loops_left()
	return loops


func get_total_elapsed_time() -> float:
	var time := 0.0
	for tween in _tweens:
		if tween.get_total_elapsed_time() > time:
			time = tween.get_total_elapsed_time()
	return time


func is_running() -> bool:
	return _tweens.any(func(tween: Tween) -> bool: return tween.is_running())


func is_valid() -> bool:
	return _tweens.any(func(tween: Tween) -> bool: return tween.is_valid())


func kill() -> void:
	for tween in _tweens:
		tween.kill()


func parallel() -> TweenArray:
	for tween in _tweens:
		tween.parallel()
	return self


func pause() -> void:
	for tween in _tweens:
		tween.pause()


func play() -> void:
	for tween in _tweens:
		tween.play()


@warning_ignore("shadowed_global_identifier")
func set_ease(ease: Tween.EaseType) -> TweenArray:
	for tween in _tweens:
		tween.set_ease(ease)
	return self


func set_loops(loops: int = 0) -> TweenArray:
	for tween in _tweens:
		tween.set_loops(loops)
	return self


@warning_ignore("shadowed_variable")
func set_parallel(parallel: bool = true) -> TweenArray:
	for tween in _tweens:
		tween.set_parallel(parallel)
	return self


func set_pause_mode(mode: Tween.TweenPauseMode) -> TweenArray:
	for tween in _tweens:
		tween.set_pause_mode(mode)
	return self


func set_process_mode(mode: Tween.TweenProcessMode) -> TweenArray:
	for tween in _tweens:
		tween.set_process_mode(mode)
	return self


func set_speed_scale(speed: float) -> TweenArray:
	for tween in _tweens:
		tween.set_speed_scale(speed)
	return self


func set_trans(trans: Tween.TransitionType) -> TweenArray:
	for tween in _tweens:
		tween.set_trans(trans)
	return self


func stop() -> void:
	for tween in _tweens:
		tween.stop()


func tween_callback(callback: Callable) -> CallbackTweenerArray:
	var tweeners: Array[Tweener] = []
	for tween in _tweens:
		tweeners.append(tween.tween_callback(callback))
	return CallbackTweenerArray.new(tweeners)


func tween_interval(time: float) -> IntervalTweenerArray:
	var tweeners: Array[Tweener] = []
	for tween in _tweens:
		tweeners.append(tween.tween_interval(time))
	return IntervalTweenerArray.new(tweeners)


func tween_method(method: Callable, from: Variant, to: Variant, duration: float) -> MethodTweenerArray:
	var tweeners: Array[Tweener] = []
	for tween in _tweens:
		tweeners.append(tween.tween_method(method, from, to, duration))
	return MethodTweenerArray.new(tweeners)


func tween_property(object: Object, property: NodePath, final_val: Variant, duration: float) -> PropertyTweenerArray:
	var tweeners: Array[Tweener] = []
	for tween in _tweens:
		tweeners.append(tween.tween_property(object, property, final_val, duration))
	return PropertyTweenerArray.new(tweeners)


class TweenerArray:
	var _tweeners: Array[Tweener] = [] :
		set(value):
			_tweeners = value
			await Promise.new(value.map(func(tweener: Tweener) -> Signal: return tweener.finished)).all()
			finished.emit()
	
	func _init(tweeners: Array[Tweener] = []) -> void:
		_tweeners = tweeners
	
	signal finished()


class CallbackTweenerArray extends TweenerArray:
	func set_delay(delay: float) -> CallbackTweenerArray:
		for tweener in _tweeners:
			tweener.set_delay(delay)
		return self


class IntervalTweenerArray extends TweenerArray:
	pass


class MethodTweenerArray extends TweenerArray:
	func set_delay(delay: float) -> MethodTweenerArray:
		for tweener in _tweeners:
			tweener.set_delay(delay)
		return self
	
	@warning_ignore("shadowed_global_identifier")
	func set_ease(ease: Tween.EaseType) -> MethodTweenerArray:
		for tweener in _tweeners:
			tweener.set_ease(ease)
		return self
	
	func set_trans(trans: Tween.TransitionType) -> MethodTweenerArray:
		for tweener in _tweeners:
			tweener.set_trans(trans)
		return self


class PropertyTweenerArray extends TweenerArray:
	func as_relative() -> PropertyTweenerArray:
		for tweener in _tweeners:
			tweener.as_relative()
		return self
	
	func from(value: Variant) -> PropertyTweenerArray:
		for tweener in _tweeners:
			tweener.from(value)
		return self
	
	func from_current() -> PropertyTweenerArray:
		for tweener in _tweeners:
			tweener.from_current()
		return self
	
	func set_delay(delay: float) -> PropertyTweenerArray:
		for tweener in _tweeners:
			tweener.set_delay(delay)
		return self
	
	@warning_ignore("shadowed_global_identifier")
	func set_ease(ease: Tween.EaseType) -> PropertyTweenerArray:
		for tweener in _tweeners:
			tweener.set_ease(ease)
		return self
	
	func set_trans(trans: Tween.TransitionType) -> PropertyTweenerArray:
		for tweener in _tweeners:
			tweener.set_trans(trans)
		return self
