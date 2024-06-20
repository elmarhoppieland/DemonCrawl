extends RefCounted
class_name RequestBlocker

# ==============================================================================
var can_request := true
# ==============================================================================
signal lowered()
# ==============================================================================

func block() -> void:
	can_request = false


func lower() -> void:
	can_request = true
	lowered.emit()


func wait() -> void:
	while not can_request:
		await lowered
	
	block()
