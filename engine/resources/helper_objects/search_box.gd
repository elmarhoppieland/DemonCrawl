@tool
extends LineEdit
class_name SearchBox

# ==============================================================================
@export var wait_enabled := true
@export_range(0.001, 4096.0, 0.001, "exp", "or_greater", "suffix:s") var wait_time := 1.0 :
	set(value):
		wait_time = value
		_timer.wait_time = value
# ==============================================================================
var _timer := Timer.new()
# ==============================================================================
signal timeout(search: String)
# ==============================================================================

func _init() -> void:
	placeholder_text = "Search..."
	text_changed.connect(func(new_text: String) -> void:
		if wait_enabled:
			_timer.start()
		else:
			timeout.emit(new_text)
	)
	_timer.timeout.connect(func() -> void:
		timeout.emit(text)
	)
	_timer.one_shot = true


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_timer.queue_free()


func _enter_tree() -> void:
	add_child.call_deferred(_timer)


func _exit_tree() -> void:
	remove_child(_timer)
