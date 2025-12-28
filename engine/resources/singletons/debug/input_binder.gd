extends PanelContainer
class_name InputBinder

# ==============================================================================
const NO_ACTION_TEXT := "No action pressed"
# ==============================================================================
var _event: InputEvent
# ==============================================================================
@onready var _input_label: Label = %InputLabel
# ==============================================================================
signal event_selected(event: InputEvent)
signal cancelled()
# ==============================================================================

func _ready() -> void:
	hide()
	
	visibility_changed.connect(func() -> void:
		if not visible:
			return
		
		_input_label.text = NO_ACTION_TEXT
	)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event is InputEventJoypadMotion or event is InputEventMouse:
		return
	
	if event.is_released():
		return
	
	_input_label.text = event.as_text()
	_event = event


func _on_confirm_button_pressed() -> void:
	event_selected.emit(_event)
	hide()


func _on_cancel_button_pressed() -> void:
	cancelled.emit()
	hide()
