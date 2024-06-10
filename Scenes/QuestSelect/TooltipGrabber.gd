extends Grabber
class_name TooltipGrabber

# ==============================================================================
@export_multiline var text := ""
@export_multiline var subtext := ""
@export var translate := true
@export var c_unescape := false
@export var max_line_length := 32
# ==============================================================================
signal about_to_show()
# ==============================================================================

func hover() -> void:
	about_to_show.emit()
	
	if text.is_empty():
		return
	
	if subtext.is_empty():
		Tooltip.show_text(tr(text) if translate else text)
		return
	
	Tooltip.max_length = max_line_length
	Tooltip.show_text("%s\n[color=gray]%s[/color]" % [
		(tr(text) if translate else text).c_unescape(),
		tr(subtext) if translate else subtext
	])


func unhover() -> void:
	Tooltip.hide_text()


func interact() -> void:
	hover()
