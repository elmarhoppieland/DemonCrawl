@abstract
extends Resource
class_name DifficultyBase

## Stores information about a difficulty.

# ==============================================================================
signal begin_button_visibility_requested(visible: bool)
# ==============================================================================

## Returns this difficulty's name, as a translation [String].
func get_name_id() -> String:
	return _get_name_id()


## Virtual method. Should return this difficulty's name, as a translation [String].
@abstract func _get_name_id() -> String


## Returns the icon of this difficulty.
func get_icon() -> Texture2D:
	return _get_icon()


## Virtual method. Should return this difficulty's icon.
@abstract func _get_icon() -> Texture2D


## Creates & returns the currently selected quest.
func begin_selected_quest() -> Quest:
	return _begin_selected_quest()


## Virtual method. Should create & return the currently selected quest.
@abstract func _begin_selected_quest() -> Quest


## Applies this difficulty's starting values to the given [param quest].
func apply_starting_values(quest: Quest) -> void:
	_apply_starting_values(quest)


## Virtual method. Should apply this difficulty's starting values to the given [param quest].
@abstract func _apply_starting_values(quest: Quest) -> void


## Returns the node that allow the player to select or create a quest.
## [br][br]For Casual, Normal, and Hard, this returns one node for every quest in
## the difficulty. For Beyond, this returns 3 nodes to select stages, one node for
## the [Emblem], and one node for the [Glint].
func get_quest_selection_node() -> Node:
	return _get_quest_selection_node()


## Virtual method. Should returns node to allow the player to select or create
## a quest for this difficulty. See [method get_quest_selection_node].
@abstract func _get_quest_selection_node() -> Node


## Returns the node that shows details about the selected quest, or that allows
## the player to specify the details of the quest.
func get_quest_details_node() -> Node:
	return _get_quest_details_node()


## Virtual method. Should return the node that shows details about the selected
## quest, or that allows the player to specify the details of the quest.
@abstract func _get_quest_details_node() -> Node


## Selects the quest at the given [param quest_index].
func select_quest_index(quest_index: int) -> void:
	_select_quest_index(quest_index)


## Virtual method. Should select the quest at the given [param quest_index].
@abstract func _select_quest_index(quest_index: int) -> void


## Returns [code]true[/code] if this difficulty is unlocked.
func is_unlocked() -> bool:
	return _is_unlocked()


## Virtual method. Should return [code]true[/code] if this difficulty is unlocked,
## and [code]false[/code] otherwise.
@abstract func _is_unlocked() -> bool


## Parses the given [param guaranteed_objects]. Returns a new [Array], containing
## the new guaranteed objects.
## [br][br][b]Note:[/b] This method may mutate the given [Array]. Consider using
## [method Array.duplicate] if this is not desired.
func parse_guaranteed_objects(guaranteed_objects: Array[CellObject]) -> Array[CellObject]:
	return _parse_guaranteed_objects(guaranteed_objects)


## Virtual method. Should parse the given [param guaranteed_objects], adding or
## removing any number of [CellObject]s. Should return the new [Array].
@abstract func _parse_guaranteed_objects(guaranteed_objects: Array[CellObject]) -> Array[CellObject]


## Shows the next quest to unlock, using [DCPopup].
func show_next_quest_unlock(quest_played: QuestFile) -> void:
	_show_next_quest_unlock(quest_played)


## Virtual method. Called when the given quest is finished, and should use [DCPopup]
## to show which quest has been unlocked.
@warning_ignore("unused_parameter")
func _show_next_quest_unlock(quest_played: QuestFile) -> void:
	pass


## Shows the begin button. The begin button is visible by default.
func show_begin_button() -> void:
	begin_button_visibility_requested.emit(true)


## Hides the begin button. The begin button is visible by default.
func hide_begin_button() -> void:
	begin_button_visibility_requested.emit(false)
