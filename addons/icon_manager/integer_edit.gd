@tool
extends LineEdit

# ==============================================================================
@export var value := 0 :
	set(new_value):
		value = new_value
		
		var caret := caret_column
		text = str(new_value)
		caret_column = caret
		
		value_changed.emit(new_value)
# ==============================================================================
signal value_changed(new_value: int)
# ==============================================================================

func _ready() -> void:
	value = 0
	
	text_changed.connect(func(new_text: String) -> void:
		if not new_text.is_empty():
			value = new_text.to_int()
	)
	text_submitted.connect(func(_new_text: String) -> void:
		release_focus()
	)
