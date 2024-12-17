extends Grabber
class_name TooltipGrabber

# ==============================================================================
@export_multiline var text := "" ## The text to be displayed (in white) as the first line in the tooltip. If this is empty, no tooltip will be shown.
@export_multiline var subtext := "" ## The subtext to be displayed (in gray) underneath the [member text]. If this is empty, only the [member text] will be shown.
@export var translate := true ## Whether both the [member text] and the [member subtext] should be translated before being shown.
@export var c_unescape := false ## Whether all escape sequences (e.g. [code]\n[/code]) should be unescaped before showing the tooltip.
@export var max_line_length := 32 ## The maximum number of characters on each line of the tooltip. If more characters are on the line, a newline is inserted.
# ==============================================================================
signal about_to_show() ## Emitted before showing the tooltip. The [member text] and [member subtext] can still be changed on connected callables and their changed values will be shown.
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
