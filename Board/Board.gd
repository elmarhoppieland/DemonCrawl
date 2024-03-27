extends TileMap
class_name Board

## The Minesweeper board.
## 
## The board that contains all cells. This singleton handles cell hovering, pressing, releasing, etc.
## [br][br][b]Note:[/b] All non-private properties and methods are static and should be called on
## the class, e.g. [code]Board.get_cell(Vector2i(3, 8))[/code].
## [br][br][b]Note:[/b] All [Signal]s that start with an underscore ([code]_[/code]) are private.
## Instead, use their respective (static) properties without a leading underscore.

# ==============================================================================
const CELL_SIZE := Vector2i(16, 16)
# ==============================================================================
static var _cells := {}
static var _cell_data := {}
static var _instance: Board

static var cell_hovered: Signal ## Emitted when a cell gets hovered.
static var cell_pressed: Signal ## Emitted when a cell gets pressed.
static var cell_released: Signal ## Emitted when a cell gets released.
static var cell_flagged: Signal ## Emitted when a cell gets flagged or unflagged.
static var cells_generated: Signal ## Emitted when all cells have been generated.

static var rng := RandomNumberGenerator.new() ## The [RandomNumberGenerator] used to generate boards. Use [member RandomNumberGenerator.seed] to make boards generate consistently.

static var started := false ## Whether the board has been started, i.e. whether the first cell has been pressed. Before this, the board has been generated, but monsters may be moved depending on the first click.

static var size := Vector2i.ZERO ## The number of cells in each row and column.
# ==============================================================================
var _previous_hovered_cell: Cell
var _pressed_cell: Cell
# ==============================================================================
@onready var _finish_button: MarginContainer = %FinishButton
@onready var _color_rect: ColorRect = %ColorRect
# ==============================================================================
signal _cell_hovered(cell: Cell)
signal _cell_pressed(cell: Cell)
signal _cell_released(cell: Cell)
signal _cell_flagged(cell: Cell)

signal _cells_generated()
# ==============================================================================

func _enter_tree() -> void:
	cell_hovered = _cell_hovered
	cell_pressed = _cell_pressed
	cell_released = _cell_released
	cell_flagged = _cell_flagged
	cells_generated = _cells_generated
	
	_instance = self


func _ready() -> void:
	Statbar.add_item(preload("res://Assets/items/Apple.gd").new())
	
	_cell_data = Minesweeper.generate_board(Vector2i(10, 10), 20, Quest.current_stage.name, rng)
	for map_pos in _cell_data:
		set_cell(0, map_pos, 0, Vector2i.ZERO, 1)
	
	_color_rect.color.a = 1
	create_tween().tween_property(_color_rect, "color:a", 0, 1)
	
	child_entered_tree.connect(func(cell: Cell):
		var map_pos := Vector2i(cell.position) / tile_set.tile_size
		cell.board_position = map_pos
		_cells[map_pos] = cell
		cell.load_data(_cell_data[map_pos])
		
		if map_pos.x + 1 > size.x and map_pos.y + 1 > size.y:
			Board.size = map_pos + Vector2i.ONE
		
		if _cells.size() == _cell_data.size():
			cells_generated.emit()
	)
	
	cell_pressed.connect(func(cell: Cell):
		if _pressed_cell:
			_pressed_cell.unpress()
		_pressed_cell = cell
		cell.press()
	)
	
	cell_released.connect(func(cell: Cell):
		if not Board.started:
			_start_board(cell)
		
		cell.open()
		_pressed_cell = null
		
		Board.check_completion()
	)
	
	cell_flagged.connect(func(cell: Cell):
		cell.flag()
	)
	
	cells_generated.connect(func():
		for cell: Cell in _cells.values():
			cell.reset_value()
	)


func _process(_delta: float) -> void:
	_process_cells()


func _process_cells() -> void:
	var mouse_pos := get_local_mouse_position()
	var map_pos := local_to_map(mouse_pos)
	var cell := Board.get_cell(map_pos)
	
	if cell:
		if cell != _previous_hovered_cell:
			cell_hovered.emit(cell)
			if Input.is_action_pressed("cell_open"):
				cell_pressed.emit(cell)
		
		if Input.is_action_just_pressed("cell_flag"):
			cell_flagged.emit(cell)
		
		if Input.is_action_just_pressed("cell_open"):
			cell_pressed.emit(cell)
		
		if Input.is_action_just_released("cell_open"):
			cell_released.emit(_pressed_cell)
	
	_previous_hovered_cell = cell


func _start_board(cell: Cell) -> void:
	if cell.cell_value > 0 or cell.has_monster():
		var nearby_cells := cell.get_nearby_cells()
		nearby_cells.append(cell)
		
		var available_cells := _cells.values().filter(func(a: Cell): return not a.has_monster() and not a in nearby_cells)
		
		for nearby_cell in nearby_cells:
			if nearby_cell.has_monster():
				var random := rng.randi_range(0, available_cells.size())
				var new_cell: Cell = available_cells.pop_at(random)
				new_cell.cell_object = nearby_cell.cell_object
				nearby_cell.cell_object = null
		
		for any_cell in _cells.values():
			any_cell.reset_value()
	
	Board.started = true


## Checks for completion. If all cells without a monster have been revealed, shows the finish button and flags all hidden cells.
static func check_completion() -> void:
	if _cells.values().all(func(cell: Cell): return cell.revealed or cell.has_monster()):
		_instance._finish_button.show()
		
		for cell: Cell in _cells.values():
			if not cell.revealed and not cell.flagged:
				cell.flag()


## Returns the cell at the given map position. Returns [code]null[/code] if the cell does not exist.
static func get_cell(at: Vector2i) -> Cell:
	return _cells.get(at)


func _on_finish_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/StageSelect/StageSelect.tscn")


func _exit_tree() -> void:
	_cells.clear()
	_cell_data.clear()
	started = false
