extends RefCounted
class_name CellObject

## A [Cell]'s object.

# ==============================================================================
var cell: Cell ## The [Cell] this is the object of.
# ==============================================================================

func _init(_cell: Cell) -> void:
	cell = _cell


## Clears this [CellObject], setting the cell's [member Cell.cell_object] to [code]null[/code].
func clear() -> void:
	cell.cell_object = null


## Returns the object's texture.
func get_texture() -> Texture2D:
	return null


## Returns the object's color palette, to be inserted into the cell's shader.
func get_palette() -> Texture2D:
	return null


## Returns the texture's animation frame duration, or [code]NAN[/code] if it does not have an animation.
func get_animation_delta() -> float:
	return NAN


## Called when the player interacts (left-click or Q) with this object.
func interact() -> void:
	hover()


## Called when the player uses secondary interact (right-click or E) on this object.
func secondary_interact() -> void:
	pass


## Called when the player starts hovering over this object.
## [br][br]The default behaviour shows a [Tooltip], if [method get_tooltip_text]
## does not return an empty [String]. Call [code]super()[/code] when overriding
## this method to keep this behaviour.
func hover() -> void:
	var text := get_tooltip_text()
	if text.is_empty():
		return
	Tooltip.show_text(text)


## Called when the player stops hovering over this object.
## [br][br]The default behaviour hides the [Tooltip] shown when the player started
## hovering, if [method get_tooltip_text] did not return an empty [String].
## Call [code]super()[/code] when overriding this method to keep this behaviour.
func unhover() -> void:
	Tooltip.hide_text()


## Returns the text that should be in the tooltip when the player hovers over this object.
## [br][br]When this returns an empty [String] ([code]""[/code]), does not show a tooltip (default behaviour).
func get_tooltip_text() -> String:
	return ""


## Called when this object is revealed by any means.
func reveal() -> void:
	pass


## Called when the player actively reveals this object, typically by directly
## opening this cell or chording an adjacent cell.
func reveal_active() -> void:
	pass


## Called when the player passively reveals this object, typically by using
## items or other abilities.
func reveal_passive() -> void:
	pass


## Called at the end of a stage when determining the charitable score.
## Should return the amount of points this object gives.
func get_charitable_amount() -> int:
	return 0


## Called at the end of a stage when determining the charitable score.
## Should return [code]true[/code] if this object gives any charitable score, or [code]false[/code] if not.
func is_charitable() -> bool:
	return false
