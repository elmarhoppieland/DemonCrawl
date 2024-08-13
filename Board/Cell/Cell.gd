@tool
extends MarginContainer
class_name Cell

## A single cell in a [Board].

# ==============================================================================
const _NEIGHBORS: Array[Vector2i] = [
	Vector2i.UP + Vector2i.LEFT,
	Vector2i.UP,
	Vector2i.UP + Vector2i.RIGHT,
	Vector2i.RIGHT,
	Vector2i.DOWN + Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.DOWN + Vector2i.LEFT,
	Vector2i.LEFT
]
# ==============================================================================
enum State {
	UNINITIALIZED,
	HIDDEN,
	FLAGGED,
	REVEALED,
}
# ==============================================================================
static var _pressed_cell: Cell
static var _hovered_cell: Cell
# ==============================================================================
## This cell's theme. Its sprites are pulled from this directory inside [code]res://Assets/skins[/code].
#var theme := ""
@export var cell_value := 0 : ## This cell's value, i.e. the number of adjacent monsters.
	set(value):
		cell_value = value
		if not is_node_ready():
			await ready
		_value_label.cell_value = value
	get:
		if not _value_label:
			return cell_value
		return _value_label.cell_value
@export_enum("none", "burning", "frozen", "toxic", "cursed", "sanctified", "ethereal", "electric") var aura := "" :
	set(value):
		aura = value
		if not is_node_ready():
			await ready
		
		var color := Color.WHITE
		match value:
			"", "none":
				color = Color.WHITE
			"burning":
				color = Color.RED
			"frozen":
				color = Color.AQUA
			"toxic":
				color = Color.DARK_GREEN
			"cursed":
				color = Color.DIM_GRAY
			"sanctified":
				color = Color.GOLD
			"ethereal":
				color = Color.BLUE
			"electric":
				color = Color.MEDIUM_AQUAMARINE
		
		_background.modulate = EffectManager.propagate_value("get_aura_color", color, [aura, self])
# ==============================================================================
var board_position := Vector2i.ZERO ## This cell's [Board] coordinates.

var cell_object: CellObject : ## This cell's [CellObject], e.g. loot or a monster.
	set(value):
		cell_object = value
		if not is_node_ready():
			await ready
		
		if value == null and has_monster():
			for cell in get_nearby_cells():
				cell.cell_value -= 1
				if cell.cell_value == 0:
					cell.chord()
			if cell_value == 0:
				chord()
		
		_object_texture.cell_object = value
	get:
		if not _object_texture:
			return cell_object
		return _object_texture.cell_object

var enchants: Array[CellEnchantment] = []

var state := State.UNINITIALIZED
# ==============================================================================
var _hovered := false
var _checking := false
# ==============================================================================
@export_group("Nodes", "_")
@export var _background: CellBackground
@export var _value_label: CellValueLabel
@export var _object_texture: CellObjectTexture
@export var _flag_texture: FlagCellTexture
@export var _text_particles: TextParticles
# ==============================================================================
signal opened() ## Emitted when this cell gets opened.
signal state_changed(new_state: State) ## Emitted when this cell's [member state] changes.
# ==============================================================================

func _process(_delta: float) -> void:
	if Board.can_open_cells() and Input.is_action_just_released("cell_open") and _pressed_cell != null:
		_process_cell_opening()
		
		set_deferred("_pressed_cell", null)
	
	if not _hovered:
		return
	
	if Board.can_open_cells():
		if Input.is_action_just_pressed("cell_open") and not (is_revealed() and cell_object):
			_pressed_cell = self
			if is_revealed():
				check_chord()
			elif not is_flagged():
				check()
		elif cell_object and is_revealed():
			if Input.is_action_just_pressed("interact"):
				cell_object.interact()
			if Input.is_action_just_pressed("secondary_interact"):
				cell_object.secondary_interact()
	
	if Board.can_flag_cells() and Input.is_action_just_pressed("cell_flag"):
		if is_revealed():
			flag_chord()
		elif is_flagged():
			unflag()
		else:
			flag()


func _process_cell_opening() -> void:
	if not Cell._is_pressed_cell_hovered():
		uncheck()
		return
	
	if _pressed_cell.is_revealed():
		_process_cell_chording()
	elif _pressed_cell == self and is_checking():
		_process_direct_cell_opening()


func _process_cell_chording() -> void:
	if not _pressed_cell.is_solved():
		uncheck()
		return
	
	if not _pressed_cell.is_solved():
		return
	
	if is_checking():
		open()
	elif _pressed_cell == self and is_check_chording():
		PlayerStats.process_chain(cell_value)
		EffectManager.propagate_call.call_deferred("turn")


func _process_direct_cell_opening() -> void:
	open()
	PlayerStats.process_chain(cell_value)
	EffectManager.propagate_call.call_deferred("turn")


func _on_mouse_entered() -> void:
	_hovered = true
	_hovered_cell = self
	
	if is_revealed() and is_occupied():
		cell_object.hover()
	
	Debug.push_debug(Board._instance, "Hovered Cell Position", board_position)


func _on_mouse_exited() -> void:
	_hovered = false
	if _hovered_cell == self:
		_hovered_cell = null
	
	if is_revealed() and is_occupied():
		cell_object.unhover()


func check_chord() -> void:
	for cell in get_nearby_cells():
		if not cell.is_revealed() and not cell.is_flagged():
			cell.check()


func check() -> void:
	if is_checking():
		return
	_background.set_checking()
	set_deferred("_checking", true)


func uncheck() -> void:
	if not is_checking():
		return
	_background.set_hidden()
	set_deferred("_checking", false)


func chord() -> void:
	if cell_value == get_nearby_flags():
		for cell in get_nearby_cells():
			cell.open()
		return
	
	for cell in get_nearby_cells():
		if not cell.is_revealed():
			cell.uncheck()


func open() -> void:
	if is_revealed():
		return
	
	if Board.state == Board.State.UNINITIALIZED:
		Board.start_board(self)
	
	set_deferred("_checking", false)
	
	set_open()
	
	if cell_object:
		cell_object.reveal()
		cell_object.reveal_active()
	
	if has_monster():
		Board.update_monster_count()
	
	Board.check_completion()
	
	opened.emit()
	
	EffectManager.propagate_call("cell_open", [self])
	
	give_mana()
	
	if cell_value != 0:
		return
	
	if not is_occupied():
		spawn_loot()
	if not has_monster():
		chord()


func flag_chord() -> void:
	var count := 0
	for cell in get_nearby_cells():
		if not cell.is_revealed() or (cell.has_monster() and cell.is_revealed()):
			count += 1
	
	if count > cell_value:
		return
	
	for cell in get_nearby_cells():
		if not cell.is_revealed() and not cell.is_flagged():
			cell.flag()


func unflag() -> void:
	if state != State.FLAGGED:
		return
	
	set_hidden()
	
	Board.update_monster_count()


func flag(update_flagless: bool = true) -> void:
	if state == State.FLAGGED:
		return
	
	set_flagged()
	
	_flag_texture.play_flag()
	
	if update_flagless:
		Board.is_flagless = false
	
	Board.update_monster_count()


func set_open() -> void:
	if state == State.REVEALED:
		return
	
	state = State.REVEALED
	
	_background.set_open()
	
	if cell_object:
		_object_texture.texture = cell_object.get_texture()
		_object_texture.play_anim()
	
	state_changed.emit(state)


func set_hidden() -> void:
	if state == State.HIDDEN:
		return
	
	state = State.HIDDEN
	
	_background.set_hidden()
	
	_object_texture.texture = null
	
	state_changed.emit(state)


func set_flagged() -> void:
	if state == State.FLAGGED:
		return
	
	state = State.FLAGGED
	
	_background.set_flag()
	
	state_changed.emit(state)


func set_state(new_state: State) -> void:
	if state == new_state:
		return
	
	match new_state:
		State.HIDDEN:
			set_hidden()
		State.FLAGGED:
			set_flagged()
		State.REVEALED:
			set_open()


func add_text_particle(text: String, color_preset: TextParticles.ColorPreset) -> void:
	_text_particles.text = text
	_text_particles.text_color_preset = color_preset
	_text_particles.emitting = true
	_text_particles.restart()


## Sets this cell's value to the number of adjacent monsters.
func reset_value() -> void:
	cell_value = 0
	for cell in get_nearby_cells():
		if cell.has_monster():
			cell_value += 1


## Enchants this cell with the given [CellEnchantment].
func enchant(script: Script) -> CellEnchantment:
	var enchantment: CellEnchantment = script.new(self)
	enchants.append(enchantment)
	return enchantment


func spawn_loot() -> CellObject:
	var density := float(Quest.get_selected_stage().monsters) / Board.grid.area()
	var i := RNG.randfn(density)
	if i < 0.1:
		return null
	if i < 1:
		return spawn(CellCoin)
	if i < 1.5:
		return spawn(CellDiamond)
	if i < 2:
		return spawn(CellChest)
	
	return spawn(CellChest)


## Spawns a new object in this cell, if it is not occupied.
## [br][br][b]Note:[/b] The provided [code]script[/code] [b]must[/b] extend [CellObject].
func spawn(script: Script) -> CellObject:
	if cell_object:
		return null
	cell_object = script.new(board_position)
	return cell_object


## Gives mana to all items in the player's inventory.
func give_mana() -> void:
	Inventory.gain_mana(EffectManager.propagate_posnum("cell_get_mana", cell_value, [self]))


## Returns all cells orthogonally or diagonally adjacent to this cell. See also [method Board.get_cell].
func get_nearby_cells() -> Array[Cell]:
	var cells: Array[Cell] = []
	
	for offset in _NEIGHBORS:
		var cell := Board.get_cell(board_position + offset)
		if cell:
			cells.append(cell)
	
	return cells


## Returns the number of nearby flags.
func get_nearby_flags() -> int:
	var count := 0
	for cell in get_nearby_cells():
		count += int(cell.is_flagged() or (cell.has_monster() and cell.is_revealed()))
	return count


## Returns whether this cell's object is a monster, even if this cell is hidden.
func has_monster() -> bool:
	return cell_object and cell_object is CellMonster


func get_sprite_material() -> ShaderMaterial:
	return _object_texture.material


func get_group() -> Array[Cell]:
	var group: Array[Cell] = []
	var to_explore: Array[Cell] = [self]
	var visited: Array[Cell] = []
	
	while not to_explore.is_empty():
		var current_cell: Cell = to_explore.pop_front()
		if current_cell in visited:
			continue
		
		visited.append(current_cell)
		group.append(current_cell)
		
		for cell in current_cell.get_nearby_cells():
			if not cell in visited and cell.cell_value == cell_value:
				to_explore.append(cell)
	
	return group


## Returns whether the number of nearby identified monsters is equal to or greater than this cell's value.
## [br][br]An identified monster is a flagged cell (even if it does not have a monster) or a visible monster.
func is_solved() -> bool:
	var nearby_monsters := 0
	for cell in get_nearby_cells():
		if cell.is_revealed():
			if cell.has_monster():
				nearby_monsters += 1
		elif cell.is_flagged():
			nearby_monsters += 1
	
	return nearby_monsters >= cell_value


## Returns whether this cell is occupied, i.e. whether it has an object.
func is_occupied() -> bool:
	return cell_object != null


## Returns whether this cell is flagged.
func is_flagged() -> bool:
	return state == State.FLAGGED


## Returns whether this cell is being checked, i.e. visually pressed down.
func is_checking() -> bool:
	return _checking


## Returns whether any nearby cell is being checked. See also [method is_checked].
func is_check_chording() -> bool:
	for cell in get_nearby_cells():
		if cell.is_checking():
			return true
	
	return false


## Returns whether this cell has an aura.
func has_aura() -> bool:
	return aura != "" and aura != "none"


func is_revealed() -> bool:
	return state == State.REVEALED


## Creates a new cell and returns it.
static func create() -> Cell:
	return ResourceLoader.load("res://Board/Cell/Cell.tscn").instantiate()


static func get_hovered_cell() -> Cell:
	return _hovered_cell


static func _is_pressed_cell_hovered() -> bool:
	return _pressed_cell._hovered


func _to_string() -> String:
	return "<%d @ %s>" % [cell_value, board_position]


func _exit_tree() -> void:
	for enchantment in enchants:
		EffectManager.unregister_object(enchantment)


func _get_property_list() -> Array[Dictionary]:
	if not Engine.is_editor_hint():
		return []
	
	return [{
		"name": "revealed",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_EDITOR
	}, {
		"name": "flagged",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_EDITOR
	}]


func _set(property: StringName, value: Variant) -> bool:
	if not Engine.is_editor_hint():
		return false
	
	match property:
		&"revealed":
			if value:
				set_open()
			elif get_meta("flagged", false):
				set_flagged()
			else:
				set_hidden()
			
			set_meta("revealed", value)
		&"flagged":
			if not is_revealed():
				if value:
					set_flagged()
				else:
					set_hidden()
			
			set_meta("flagged", value)
		_:
			return false
	
	return true


func _get(property: StringName) -> Variant:
	if not Engine.is_editor_hint():
		return null
	
	match property:
		&"revealed":
			return get_meta("revealed", false)
		&"flagged":
			return get_meta("flagged", false)
	
	return null
