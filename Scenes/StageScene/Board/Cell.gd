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
@onready var _text_particles: TextParticles = %TextParticles
@onready var _texture_shatter: TextureShatter = %TextureShatter : get = get_texture_shatter
# ==============================================================================
signal mode_changed(mode: Mode) ## Emitted when the [enum Mode] (see [method get_mode]) of this [Cell] changes.
signal value_changed(value: int) ## Emitted when the value (see [method get_value]) of this [Cell] changes.
signal object_changed(object: CellObject) ## Emitted when the object (see [method get_object]) of this [Cell] changes.
signal aura_changed(aura: Aura) ## Emitted when the [Aura] (see [method get_aura]) of this [Cell] changes.

signal changed() ## Emitted when any of this [Cell]'s properties changes.
# ==============================================================================

## Creates and returns a new [Cell] from its [PackedScene].
static func create(board_position: Vector2i = Vector2i.ZERO) -> Cell:
	var cell := preload("res://Scenes/StageScene/Board/Cell.tscn").instantiate() as Cell
	cell._board_position = board_position
	return cell


## Opens this [Cell], showing its contents.
## [br][br]Calls [method Effects.cell_open] immediately after opening the [Cell].
func open(force: bool = false, allow_loot: bool = true) -> void:
	if get_mode() == Mode.VISIBLE:
		return
	if not force and get_mode() == Mode.FLAGGED:
		return
	
	if get_value() != 0:
		_open(force, allow_loot)
		return
	
	var to_explore: Array[Cell] = [self]
	var visited: Array[Cell] = []
	
	while not to_explore.is_empty():
		var current_cell := to_explore.pop_back() as Cell
		
		visited.append(current_cell)
		current_cell._open(force, allow_loot)
		
		if current_cell.get_value() != 0 or current_cell.get_object() is Monster:
			continue
		
		for c in current_cell.get_nearby_cells():
			if c in visited or c in to_explore or c.is_revealed() or c.is_flagged():
				continue
			to_explore.append(c)


func _open(force: bool = false, allow_loot: bool = true) -> void:
	if get_mode() == Mode.VISIBLE:
		return
	if not force and get_mode() == Mode.FLAGGED:
		return
	
	set_mode(Mode.VISIBLE)
	
	Quest.get_current().get_inventory().mana_gain(get_value(), self)
	
	if allow_loot and not is_occupied() and get_value() == 0 and randf() > 0.8 * (1 - get_stage().get_density()):
		_generate_content()
		#spawn(preload("res://Assets/loot_tables/Loot.tres").generate(1 / (1 - get_stage().get_density())))
	
	if is_occupied():
		get_object().notify_revealed(not force)
	
	Effects.cell_open(self)


func _generate_content() -> void:
	var table := preload("res://Assets/loot_tables/CellContent.tres").generate() as LootTable
	if not table:
		return
	
	var content := table.generate(1 / (1 - get_stage().get_density())) as CellObjectBase
	while content and not content.can_spawn():
		content = table.generate(1 / (1 - get_stage().get_density()))
	
	spawn(content)


## Spawns an instance of the provided [CellObject] script in this [Cell], or the nearest
## empty cell if this cell is occupied.
func spawn(base: CellObjectBase, visible_only: bool = false) -> CellObject:
	if not base:
		return null
	
	if not is_occupied():
		var instance := base.create(self, get_stage())
		_set_object(instance)
		return instance
	
	var radius := 1
	while radius <= max(get_stage().size.x - get_board_position().x - 1, get_board_position().x, get_stage().size.y - get_board_position().y - 1, get_board_position().y):
		var available_cells: Array[Cell] = []
		for x in range(get_board_position().x - radius, get_board_position().x + radius + 1):
			for y in [get_board_position().y - radius, get_board_position().y + radius]:
				var cell := get_stage().get_board().get_cell(Vector2i(x, y))
				if cell and not cell.is_occupied() and not visible_only or cell.is_revealed():
					available_cells.append(cell)
		for x in [get_board_position().x - radius, get_board_position().x + radius]:
			for y in range(get_board_position().y - radius + 1, get_board_position().y + radius):
				var cell := get_stage().get_board().get_cell(Vector2i(x, y))
				if cell and not cell.is_occupied() and not visible_only or cell.is_revealed():
					available_cells.append(cell)
		
		if not available_cells.is_empty():
			var cell := available_cells.pick_random() as Cell
			cell.spawn(base)
			return
		
		radius += 1
	
	Toasts.add_toast(tr("OBJECT_OFF_WORLD").format({"object": tr("OBJECT_TYPE_" + UserClassDB.script_get_class(base.base_script).to_snake_case().to_upper())}), IconManager.get_icon_data("mastery/none").create_texture())
	return


## Spawns an existing [CellObject] in this [Cell]. If this cell is already occupied,
## the new object will silently replace the old one. This does [b]not[/b] call cleanup
## methods, so it is advised to call [method clear_object] before calling this if
## the cell is occupied.
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


## Applies the given [Aura] to this [Cell], and returns the created [Aura].
## [br][br][b]Note:[/b] Each type of [Aura] is only instanced once, and subsequent
## calls to this method will return the existing [Aura].
func apply_aura(aura: Script) -> Aura:
	var aura_instance := Aura.create(aura)
	_set_aura(aura_instance)
	if is_occupied():
		get_object().notify_aura_applied()
	return aura_instance


func send_projectile(projectile: Script, direction: Vector2i = Vector2i.ZERO) -> Projectile:
	var projectile_instance := projectile.new(get_board_position(), direction) as Projectile
	projectile_instance.register()
	return projectile_instance


## Adds a particle on this [Cell] showing the given text in the given color preset.
func add_text_particle(text: String, color: TextParticles.ColorPreset) -> void:
	_text_particles.text_color_preset = color
	_text_particles.text = text
	_text_particles.emitting = true


## Returns this [Cell]'s object's [TextureRect].
func get_object_texture_rect() -> CellObjectTextureRect:
	return %CellObjectTextureRect


## Returns this [Cell]'s [TextureShatter] instance.
func get_texture_shatter() -> TextureShatter:
	if _texture_shatter:
		return _texture_shatter
	return get_node_or_null("%TextureShatter")


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
		Vector2i.LEFT
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
		return is_flagged() == get_object() is Monster
	
	var count := 0
	for cell in get_nearby_cells():
		if cell.is_flagged() or (cell.is_revealed() and cell.get_object() is Monster):
			count += 1
	
	return count >= get_value()


## Returns whether this [Cell] has at most as many nearby hidden [Cell]s and visible
## monsters as this cell's value.
func is_flag_solved() -> bool:
	var count := 0
	for cell in get_nearby_cells():
		if cell.is_hidden() or cell.get_object() is Monster:
			count += 1
	
	return count == get_value()


## Sets the [CellData] instance of this [Cell] to [code]data[/code].
func set_data(data: CellData) -> void:
	if _data and _data.changed.is_connected(_data_changed):
		_data.changed.disconnect(_data_changed)
	
	_data = data
	
	if data and data.object:
		data.object._cell_position = get_board_position()
		data.object._stage = get_stage()
	
	_data_changed()
	if data:
		data.changed.connect(_data_changed)


func _data_changed() -> void:
	mode_changed.emit(get_mode())
	value_changed.emit(get_value())
	object_changed.emit(get_object())
	aura_changed.emit(get_aura())
	
	changed.emit()


## Returns the [CellData] instance of the [Cell].
## [br][br]Prefer using [method get_mode], [method get_value] or [method get_object]
## if only one of those values is needed.
func get_data() -> CellData:
	return _data


func _set_object(value: CellObject) -> void:
	if value:
		value._cell_position = _board_position
		value.notify_spawned()
	_data.object = value
	object_changed.emit(value)


## Returns this [Cell]'s [CellObject], if it has one. Returns [code]null[/code] if
## this [Cell] has no object.
## [br][br]See also [method is_occupied].
func get_object() -> CellObject:
	if get_data():
		return get_data().object
	return null


## Removes this [Cell]'s [CellObject], if it has one.
func clear_object() -> void:
	get_object().reset()
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
	if _data:
		return _data.mode
	return Cell.Mode.INVALID


## Sets the value of this [Cell] to [code]value[/code]. The value typically indicates
## the number of nearby monsters, but can be changed by many effects.
func set_value(value: int) -> void:
	_data.value = value
	value_changed.emit(value)


## Returns this [Cell]'s value. This is usually the amount of nearby monsters, but
## various effects can change a [Cell]'s value to other values.
func get_value() -> int:
	if _data:
		return _data.value
	return 0


## Returns this [Cell]'s position on the [Board].
func get_board_position() -> Vector2i:
	return _board_position


func _set_aura(aura: Aura) -> void:
	get_data().aura = aura
	if is_occupied():
		get_object().notify_aura_changed()


## Returns this [Cell]'s [Aura], if it has one. See also [method has_aura].
func get_aura() -> Aura:
	if get_data():
		return get_data().aura
	return null


## Returns whether this [Cell] has an [Aura].
func has_aura() -> bool:
	return get_aura() != null


## Returns this [Cell]'s [Stage].
## [br][br][b]Note:[/b] Currently, this method always returns the current [Stage].
## However, this may change in the future.
func get_stage() -> Stage:
	return Stage.get_current()


func _get_minimum_size() -> Vector2:
	return CELL_SIZE


func _on_interacted() -> void:
	if is_occupied() and is_revealed():
		get_object().notify_interacted()
