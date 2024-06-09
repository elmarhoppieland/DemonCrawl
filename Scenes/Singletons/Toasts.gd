extends CanvasLayer
class_name Toasts

## Singleton that handles [Toast]s.

# ==============================================================================
static var _instance: Toasts

static var debug_alerts: bool = SavesManager.get_setting("debug_alerts", Toasts, false)
# ==============================================================================
@onready var _toasts_container: VBoxContainer = %ToastsContainer
# ==============================================================================

func _init() -> void:
	assert(not _instance, "Can only have one instance of Singleton '%s'. Use static functions instead." % name)
	
	_instance = self


## Adds a debug toast to the player's screen, if [member debug_alerts] is [code]true[/code]. Also logs the message.
static func add_debug_toast(text: String) -> Toast:
	return add_toast(text, null, true)


## Adds a toast to the player's screen.
## [br][br]The given [code]icon[/code] can be [code]null[/code] to have no icon.
static func add_toast(text: String, icon: Texture2D, debug_toast: bool = false) -> Toast:
	if debug_toast and not debug_alerts:
		Debug.log_event(text, Color.WHITE)
		return
	
	var toast := Toast.create(text, icon)
	
	_instance._toasts_container.add_child(toast)
	
	Debug.log_event("Alert: " + text, Color.WHITE)
	
	return toast
