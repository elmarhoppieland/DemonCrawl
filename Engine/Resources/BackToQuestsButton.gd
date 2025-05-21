extends MarginContainer

# ==============================================================================
@export_multiline var hover_text := "" :
	set(value):
		hover_text = value
		if not is_node_ready():
			await ready
		tooltip_grabber.text = value
@export_multiline var hover_subtext := "" :
	set(value):
		hover_subtext = value
		if not is_node_ready():
			await ready
		tooltip_grabber.subtext = value
# ==============================================================================
var mouse_is_inside := false
# ==============================================================================
@onready var tooltip_grabber: TooltipGrabber = %TooltipGrabber
# ==============================================================================
signal pressed()
# ==============================================================================

func _ready() -> void:
	tooltip_grabber.interacted.connect(func():
		pressed.emit()
	)
