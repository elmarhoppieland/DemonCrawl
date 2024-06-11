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
	
	var formatted_text := text.replace("<bullet>", "[img]Assets/sprites/bullet.png[/img]")
	var formatted_subtext := subtext.replace("<bullet>", "[img]Assets/sprites/bullet.png[/img]")
	
	if subtext.is_empty():
		Tooltip.show_text(tr(formatted_text) if translate else formatted_text)
		return
	
	Tooltip.max_length = max_line_length
	Tooltip.show_text("%s\n[color=gray]%s[/color]" % [
		(tr(formatted_text) if translate else formatted_text).c_unescape(),
		tr(formatted_subtext) if translate else formatted_subtext
	])


func unhover() -> void:
	Tooltip.hide_text()


func interact() -> void:
	hover()
