@tool
extends Control
class_name Cell

## A cell on a [Board].

# ==============================================================================
## The various states a [Cell] can be in.
enum Mode {
	INVALID = -1, ## Used as an invalid mode. A [Cell] may never have this mode.
	HIDDEN, ## The [Cell] is hidden, i.e. not yet revealed, but the cell is not flagged.
	VISIBLE, ## The [Cell] is visible.
	FLAGGED, ## The [Cell] is hidden and flagged.
	CHECKING ## The player is currently checking this [Cell], i.e. the cell is visually pressed down. It is still considered hidden.
}
# ==============================================================================
const CELL_SIZE := Vector2i(16, 16) ## The size of a [Cell] in pixels.
# ==============================================================================
@export var _data: CellData : set = set_data, get = get_data
# ==============================================================================
var _board_position := Vector2i.ZERO : get = get_board_position
# ==============================================================================
signal mode_changed(mode: Mode) ## Emitted when the mode (see [method get_mode]) of this [Cell] changes.
signal value_changed(value: int) ## Emitted when the value (see [method get_value]) of this [Cell] changes.
signal object_changed(object: CellObject) ## Emitted when the object (see [method get_object]) of this [Cell] changes.
# ==============================================================================

## Creates and returns a new [Cell] from its [PackedScene].
static func create(board_position: Vector2i = Vector2i.ZERO) -> Cell:
	var cell := preload("res://Scenes/StageScene/Board/Cell.tscn").instantiate() as Cell
	cell._board_position = board_position
	return cell


## Opens this [Cell], showing its contents.
## [br][br]Calls [method Effects.cell_open] immediately after opening the [Cell].
func open(force: bool = false) -> void:
	if get_mode() == Mode.VISIBLE:
		return
	if not force and get_mode() == Mode.FLAGGED:
		return
	
	set_mode(Mode.VISIBLE)
	
	Quest.get_current().get_instance().mana_gain(get_value(), self)
	
	if not is_occupied() and get_value() == 0 and randf() > 0.8 * (1 - get_stage().get_density()):
		spawn(preload("res://Assets/loot_tables/Loot.tres").generate(1 / (1 - get_stage().get_density())))
	
	if is_occupied():
		get_object().notify_revealed(force)
	
	Effects.cell_open(self)


## Spawns an instance of the provided [CellObject] script in this [Cell].
func spawn(base: CellObjectBase) -> CellObject:
	var instance := base.create(self, get_stage())
	_set_object(instance)
	return instance


## Spawns an existing [CellObject] in this [Cell].
## [br][br][br]Note:[/b] Though this method will not prevent it, using the same object
## for multiple [Cell]s may behave unexpectedly.
func spawn_instance(instance: CellObject) -> void:
	_set_object(instance)


## Checks this [Cell], visually pressing it down, if this [Cell] is hidden and not flagged.
func check() -> void:
	if get_mode() == Cell.Mode.HIDDEN:
		set_mode(Cell.Mode.CHECKING)


## Unchecks this [Cell], resetting it to [constant HIDDEN].
func uncheck() -> void:
	if get_mode() == Cell.Mode.CHECKING:
		set_mode(Cell.Mode.HIDDEN)


## Flags this [Cell]. This prevents it from being opened.
func flag() -> void:
	if get_mode() != Cell.Mode.FLAGGED and not is_revealed():
		set_mode(Cell.Mode.FLAGGED)


## Unflags this [Cell], resetting it to [constant HIDDEN].
func unflag() -> void:
	if get_mode() == Cell.Mode.FLAGGED:
		set_mode(Cell.Mode.HIDDEN)


## Returns this [Cell]'s object's [TextureRect].
func get_object_texture_rect() -> CellObjectTextureRect:
	return %CellObjectTextureRect


## Returns all [Cell]s horizontally or diagonally adjacent to this [Cell].
func get_nearby_cells() -> Array[Cell]:
	const DIRECTIONS: Array[Vector2i] = [
		Vector2i.UP + Vector2i.LEFT,
		Vector2i.UP,
		Vector2i.UP + Vector2i.RIGHT,
		Vector2i.RIGHT,
		Vector2i.DOWN + Vector2i.RIGHT,
		Vector2i.DOWN,
		Vector2i.DOWN + Vector2i.LEFT,
		Vector2.LEFT
	]
	
	var cells: Array[Cell] = []
	for dir in DIRECTIONS:
		var cell := Stage.get_current().get_board().get_cell(get_board_position() + dir)
		if cell:
			cells.append(cell)
	return cells


## Returns an [Array] of all [Cell]s with the same value as this [Cell] that are directly
## or indirectly connected to this [Cell] via other [Cell]s in the same group.
func get_group() -> Array[Cell]:
	var group: Array[Cell] = []
	var to_explore: Array[Cell] = [self]
	var visited: Array[Cell] = []
	
	while not to_explore.is_empty():
		var current_cell := to_explore.pop_back() as Cell
		
		visited.append(current_cell)
		group.append(current_cell)
		
		for cell in current_cell.get_nearby_cells():
			if cell not in visited and cell.get_value() == get_value() and cell not in to_explore:
				to_explore.append(cell)
	
	return group


## Returns whether this [Cell] is revealed, i.e. its mode (see [method get_mode])
## is set to [constant VISIBLE].
func is_revealed() -> bool:
	return get_mode() == Mode.VISIBLE


## Returns whether this [Cell] is hidden, i.e. not revealed.
## [br][br]This method is the opposite of [method is_revealed].
func is_hidden() -> bool:
	return not is_revealed()


## Returns whether this [Cell] is flagged, i.e. its mode (see [method get_mode])
## is set to [constant FLAGGED].
func is_flagged() -> bool:
	return get_mode() == Mode.FLAGGED


## Returns whether this [Cell] is being checked, i.e. its mode (see [method get_mode])
## is set to [constant CHECKING].
func is_checking() -> bool:
	return get_mode() == Mode.CHECKING


## Returns whether this [Cell] is occupied, i.e. whether it has an object.
func is_occupied() -> bool:
	return get_object() != null


## Returns whether this [Cell] is solved. This can mean 2 things:
## [br][br]If this cell is hidden, this returns true if this cell has a monster and
## is flagged, or if this cell does not have a monster and is not flagged.
## [br][br]If this cell is visible, this returns true if this cell's value is at most
## the number of nearby flags + monsters.
func is_solved() -> bool:
	if is_hidden():
		return is_flagged() == get_object() is CellMonster
	
	var count := 0
	for cell in get_nearby_cells():
		if cell.is_flagged() or (cell.is_revealed() and cell.get_object() is CellMonster):
			count += 1
	
	return count >= get_value()


## Returns whether this [Cell] has at most as many nearby hidden [Cell]s and visible
## monsters as this cell's value.
func is_flag_solved() -> bool:
	var count := 0
	for cell in get_nearby_cells():
		if cell.is_hidden():
			count += 1
		elif cell.get_object() is CellMonster:
			count += 1
	
	return count == get_value()


## Sets the [CellData] instance of this [Cell] to [code]data[/code].
func set_data(data: CellData) -> void:
	_data = data
	
	mode_changed.emit(data.mode)
	value_changed.emit(data.value)
	object_changed.emit(data.object)
	
	data.changed.connect(func() -> void:
		mode_changed.emit(data.mode)
		value_changed.emit(data.value)
		object_changed.emit(data.object)
	)


## Returns the [CellData] instance of the [Cell].
## [br][br]Prefer using [method get_mode], [method get_value] or [method get_object]
## if only one of those values is needed.
func get_data() -> CellData:
	return _data


func _set_object(value: CellObject) -> void:
	_data.object = value
	value._cell_position = _board_position
	object_changed.emit(value)


## Returns this [Cell]'s [CellObject], if it has one. Returns [code]null[/code] if
## this [Cell] has no object.
## [br][br]See also [method is_occupied].
func get_object() -> CellObject:
	return _data.object


## Removes this [Cell]'s [CellObject], if it has one.
func clear_object() -> void:
	_set_object(null)


## Sets the mode of this [Cell] to [code]mode[/code]. The mode determines the visibility
## of this [Cell] and its contents. See [enum Mode].
func set_mode(mode: Cell.Mode) -> void:
	assert(mode != Cell.Mode.INVALID, "Cells cannot have an invalid mode.")
	_data.mode = mode
	mode_changed.emit(mode)


## Returns this [Cell]'s mode. See each [enum Mode] constant for more information.
## [br][br][b]Note:[/b] Prefer using [method is_revealed], [method is_hidden], [method is_flagged]
## and [method is_checking] over this method, as some [enum Mode] constants are used
## for multiple states and can therefore behave unexpectedly.
func get_mode() -> Cell.Mode:
	return _data.mode


## Sets the value of this [Cell] to [code]value[/code]. The value typically indicates
## the number of nearby monsters, but can be changed by many effects.
func set_value(value: int) -> void:
	_data.value = value
	value_changed.emit(value)


## Returns this [Cell]'s value. This is usually the amount of nearby monsters, but
## various effects can change a [Cell]'s value to other values.
func get_value() -> int:
	return _data.value


## Returns this [Cell]'s position on the [Board].
func get_board_position() -> Vector2i:
	return _board_position


## Returns this [Cell]'s [Stage].
## [br][br][b]Note:[/b] Currently, this method always returns the current [Stage].
## However, this may change in the future.
func get_stage() -> Stage:
	return Stage.get_current()


func _get_minimum_size() -> Vector2:
	return CELL_SIZE
