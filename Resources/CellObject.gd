extends RefCounted
class_name CellObject

## A [Cell]'s object.

# ==============================================================================
var cell: Cell ## The [Cell] this is the object of.
# ==============================================================================

func _init(_cell: Cell) -> void:
	cell = _cell
	
	cell._object_texture.tooltip_grabber.about_to_show.connect(_about_to_show_tooltip)


func get_tree() -> SceneTree:
	return cell.get_tree()


## Clears this [CellObject], setting the cell's [member Cell.cell_object] to [code]null[/code].
func clear() -> void:
	cell.cell_object = null
	
	cell._object_texture.tooltip_grabber.text = ""
	cell._object_texture.tooltip_grabber.subtext = ""
	cell._object_texture.tooltip_grabber.about_to_show.disconnect(_about_to_show_tooltip)


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
func hover() -> void:
	pass


## Called when the player stops hovering over this object.
func unhover() -> void:
	pass


## Kills this object.
## [br][br]When overriding, make sure to add [code]super()[/code] to keep the default behaviour.
func kill() -> void:
	clear()


## Returns the text that should be in the tooltip when the player hovers over this object.
## [br][br]When this returns an empty [String] ([code]""[/code]), does not show a tooltip (default behaviour).
func get_tooltip_text() -> String:
	return ""


## Returns the text that should be in the tooltip subtext when the player hovers over this object.
## [br][br]When this returns an empty [String] ([code]""[/code]), does not have any subtext (default behaviour).
func get_tooltip_subtext() -> String:
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


func _about_to_show_tooltip() -> void:
	cell._object_texture.tooltip_grabber.text = get_tooltip_text()
	cell._object_texture.tooltip_grabber.subtext = get_tooltip_subtext()
