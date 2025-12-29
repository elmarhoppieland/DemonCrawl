@abstract
extends Button
class_name DebugToolButton

# ==============================================================================
@warning_ignore("unused_signal")
signal item_selected(item: Control)
# ==============================================================================

## Returns a list of [Control] nodes that represent each item, to be displayed
## in the left part of the tools overlay when this button is selected.
func get_items() -> Array[Control]:
	return _get_items()


## Virtual method. Should return a [Control] node for each item that should be
## displayed in the left part of the tools overlay when this button is selected.
@abstract func _get_items() -> Array[Control]


## Returns the [Control] node that shows [param item] in more detail. This should
## be called when the [param item] is selected.
func handle_item_selected(item: Control) -> Control:
	return _handle_item_selected(item)


## Virtual method. Called when [param item] is selected. Should return a [Control]
## node that shows the [param item] in more detail.
@abstract func _handle_item_selected(item: Control) -> Control


## Performs the given [param search] on the given [param items], setting the visibility
## of each one. Call this with an empty [param search] [String] to make all
## [param items] visible.
func handle_search(search: String, items: Array[Control]) -> void:
	_handle_search(search, items)


## Virtual method. Called when the user searches the given list of [param items].
## Should toggle visibility of each item. If [param search] is an empty [String],
## this should make every item visible.
@abstract func _handle_search(search: String, items: Array[Control]) -> void


## Returns the [DebugToolsOverlay] of this button.
func get_overlay() -> DebugToolsOverlay:
	var base := get_parent()
	while base != null and base is not DebugToolsOverlay:
		base = base.get_parent()
	return base
