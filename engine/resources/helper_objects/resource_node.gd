@tool
@abstract
extends Node
class_name ResourceNode

# ==============================================================================
var _changed_queued := false
# ==============================================================================
signal changed()
# ==============================================================================

## Queues this object to be changed. This calls [method emit_changed] once at the end
## of the current frame, regardless of how many times it was called.
func queue_changed() -> void:
	if _changed_queued:
		return
	
	_changed_queued = true
	await Promise.defer()
	_changed_queued = false
	
	emit_changed()


## Emits the [signal changed] [Signal].
func emit_changed() -> void:
	changed.emit()
