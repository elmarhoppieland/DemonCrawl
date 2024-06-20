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
static var _pressed_cell: Cell
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
var revealed := false : ## Whether this cell has been revealed.
	get:
		return _background.state == CellBackground.State.OPEN
var board_position := Vector2i.ZERO ## This cell's [Board] coordinates.

var cell_object: CellObject : ## This cell's [CellObject], e.g. loot or a monster.
	set(value):
		cell_object = value
		if not is_node_ready():
			await ready
		_object_texture.cell_object = value
	get:
		if not _object_texture:
			return cell_object
		return _object_texture.cell_object
# ==============================================================================
var _hovered := false
var _checking := false
# ==============================================================================
@onready var _background: CellBackground = %Background
@onready var _value_label: Label = %ValueLabel
@onready var _object_texture: CellObjectTexture = %ObjectTexture
@onready var _flag_texture: TextureRect = %FlagTexture
@onready var _text_particles: TextParticles = %TextParticles
# ==============================================================================
signal opened() ## Emitted when this cell gets opened.
# ==============================================================================

func _process(_delta: float) -> void:
	if not Board.frozen and Input.is_action_just_released("cell_open") and _pressed_cell != null:
		_process_cell_opening()
		
		set_deferred("_pressed_cell", null)
	
	if not _hovered:
		return
	
	if not Board.frozen:
		if Input.is_action_just_pressed("cell_open") and not (revealed and cell_object):
			_pressed_cell = self
			if revealed:
				check_chord()
			elif not is_flagged():
				check()
		elif cell_object and revealed:
			if Input.is_action_just_pressed("interact"):
				cell_object.interact()
			if Input.is_action_just_pressed("secondary_interact"):
				cell_object.secondary_interact()
	
	if Board.mutable and Input.is_action_just_pressed("cell_flag"):
		if revealed:
			flag_chord()
		elif is_flagged():
			unflag()
		else:
			flag()


func _process_cell_opening() -> void:
	if not Cell._is_pressed_cell_hovered():
		uncheck()
		return
	
	if _pressed_cell.revealed:
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


func _process_direct_cell_opening() -> void:
	open()
	PlayerStats.process_chain(cell_value)


func _on_mouse_entered() -> void:
	_hovered = true
	
	if revealed and is_occupied():
		cell_object.hover()
	
	Debug.push_debug(Board._instance, "Hovered Cell Position", board_position)


func _on_mouse_exited() -> void:
	_hovered = false
	
	if revealed and is_occupied():
		cell_object.unhover()


func check_chord() -> void:
	for cell in get_nearby_cells():
		if not cell.revealed and not cell.is_flagged():
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
			if not cell.revealed:
				cell.open()
		return
	
	for cell in get_nearby_cells():
		if not cell.revealed:
			cell.uncheck()


func open() -> void:
	if revealed:
		return
	
	if not Board.started:
		Board.start_board(self)
	
	_background.set_open()
	
	set_deferred("_checking", false)
	
	if cell_object:
		_object_texture.texture = cell_object.get_texture()
		_object_texture.play_anim()
		
		cell_object.reveal()
		cell_object.reveal_active()
	
	if has_monster():
		Board.update_monster_count()
	
	Board.check_completion()
	
	opened.emit()
	
	EffectManager.propagate_call("cell_open", [self])
	
	if cell_object and cell_object is CellMonster:
		return
	
	if cell_value == 0:
		if not cell_object:
			cell_object = CellCoin.new(self)
		chord()


func flag_chord() -> void:
	var count := 0
	for cell in get_nearby_cells():
		if not cell.revealed or (cell.has_monster() and cell.revealed):
			count += 1
	
	if count > cell_value:
		return
	
	for cell in get_nearby_cells():
		if not cell.revealed and not cell.is_flagged():
			cell.flag()


func unflag() -> void:
	if not is_flagged():
		return
	
	_background.set_hidden()
	_flag_texture.texture = null
	
	Board.update_monster_count()


func flag() -> void:
	if is_flagged():
		return
	
	_background.set_flag()
	_flag_texture.play_flag()
	
	Board.is_flagless = false
	Board.update_monster_count()


func add_text_particle(text: String, color_preset: TextParticles.ColorPreset) -> void:
	_text_particles.text = text
	_text_particles.text_color_preset = color_preset
	_text_particles.emitting = true
	_text_particles.restart()


## Loads the [CellData] into this cell.
func load_data(data: CellData) -> void:
	#theme = data.theme
	cell_value = data.cell_value
	revealed = data.revealed
	cell_object = data.cell_object


## Sets this cell's value to the number of adjacent monsters.
func reset_value() -> void:
	cell_value = 0
	for cell in get_nearby_cells():
		if cell.cell_object:
			cell_value += 1


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
		count += int(cell.is_flagged() or (cell.has_monster() and cell.revealed))
	return count


## Returns whether this cell's object is a monster, even if this cell is hidden.
func has_monster() -> bool:
	if not cell_object:
		return false
	
	return cell_object is CellMonster


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
		if cell.revealed:
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
	return _background.state == CellBackground.State.FLAG


## Returns whether this cell is being checked, i.e. visually pressed down.
func is_checking() -> bool:
	return _checking


## Returns whether any nearby cell is being checked. See also [method is_checked].
func is_check_chording() -> bool:
	for cell in get_nearby_cells():
		if cell.is_checking():
			return true
	
	return false


## Creates a new cell and returns it, after loading the given [code]data[/code] into it, if it is given.
## [br][br]See also [method load_data].
static func create(data: CellData = null) -> Cell:
	var scene: PackedScene = ResourceLoader.load("res://Board/Cell/Cell.tscn")
	var cell: Cell = scene.instantiate()
	
	if data:
		cell.load_data(data)
	
	return cell


static func _is_pressed_cell_hovered() -> bool:
	return _pressed_cell._hovered


func _to_string() -> String:
	return "<%d @ %s>" % [cell_value, board_position]
