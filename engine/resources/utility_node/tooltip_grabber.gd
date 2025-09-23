@tool
extends Grabber
class_name TooltipGrabber

# ==============================================================================
enum ContextMode {
	DISABLED, ## Do not use a [TooltipContext].
	CURRENT, ## Use the current globally active [TooltipContext].
	ANCESTOR, ## Use a [TooltipContext] that is an ancestor of this node.
}
# ==============================================================================
@export_multiline var text := "" ## The text to be displayed (in white) as the first line in the tooltip. If this is empty, no tooltip will be shown.
@export_multiline var subtext := "" ## The subtext to be displayed (in gray) underneath the [member text]. If this is empty, only the [member text] will be shown.
@export var context_mode := ContextMode.CURRENT ## The [enum ContextMode] to use.
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
	
	var context: TooltipContext
	match context_mode:
		ContextMode.DISABLED:
			context = null
		ContextMode.CURRENT:
			context = TooltipContext.get_current()
		ContextMode.ANCESTOR:
			var base := get_parent()
			while base != null and base is not TooltipContext:
				base = base.get_parent()
			context = base as TooltipContext
	
	var formatted_text := Tooltip.limit_line_length(tr(text) if translate else text, max_line_length)
	if c_unescape:
		formatted_text = formatted_text.c_unescape()
	
	if subtext.is_empty():
		Tooltip.show_text(formatted_text, context)
		return
	
	var formatted_subtext := Tooltip.limit_line_length(tr(subtext) if translate else subtext, max_line_length)
	if c_unescape:
		formatted_subtext = formatted_subtext.c_unescape()
	
	Tooltip.show_text("%s\n[color=gray]%s[/color]" % [
		formatted_text,
		formatted_subtext
	], context)


func unhover() -> void:
	Tooltip.hide_text()


func interact() -> void:
	hover.call_deferred()
