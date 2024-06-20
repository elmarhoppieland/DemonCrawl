extends Control
class_name Board

## The Minesweeper board.
## 
## The board that contains all cells. This singleton handles cell hovering, pressing, releasing, etc.
## [br][br][b]Note:[/b] All non-private properties and methods are static and should be called on
## the class, for example:
## [codeblock]
## Board.get_cell(Vector2i(3, 8))
## [/codeblock]

# ==============================================================================
const CELL_SIZE := Vector2i(16, 16)
# ==============================================================================
static var _instance: Board :
	get:
		assert(_instance != null, "Attempted to use the Board instance when it has not been instantiated.")
		return _instance

static var rng := RandomNumberGenerator.new() ## The [RandomNumberGenerator] used to generate boards. Use [member RandomNumberGenerator.seed] to make boards generate consistently.

static var started: bool = SavesManager.get_value("started", Board, false) ## Whether the board has been started, i.e. whether the first cell has been opened.
static var mutable: bool = SavesManager.get_value("mutable", Board, false) : ## Whether the board is mutable, i.e. cells can be flagged or unflagged.
	set(value):
		mutable = value
		if value:
			Board.start_time = Time.get_ticks_usec()
		else:
			Board.saved_time = Board.get_timef()
			Board.start_time = -1
static var frozen := false ## Whether the board is frozen, i.e. cells can be opened.

static var board_size: Vector2i = SavesManager.get_value("board_size", Board, Vector2i.ZERO) ## The number of cells in each row and column.

static var start_time := -1 ## The amount of ticks (microseconds) since game launch when the timer started running.
static var saved_time: float = SavesManager.get_value("saved_time", Board, 0.0) ## The timer when it was loaded.

static var board_3bv: int = SavesManager.get_value("board_3bv", Board, -1)
static var is_flagless: bool = SavesManager.get_value("is_flagless", Board, true)
# ==============================================================================
@onready var _finish_button: MarginContainer = %FinishButton
@onready var _monsters_label: Label = %MonstersLabel
@onready var _power_label: Label = %PowerLabel
@onready var _cell_container: GridContainer = %CellContainer
@onready var _finish_popup_contents: FinishPopupContents = %FinishPopupContents
@onready var _tweener_canvas: CanvasLayer = %TweenerCanvas
@onready var _animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================
signal _cells_generated()
# ==============================================================================

func _enter_tree() -> void:
	_instance = self
	
	EffectManager.register_object(self)


func _ready() -> void:
	Statbar.add_item(preload("res://Assets/items/Apple.gd").new())
	
	AssetManager.theme = StagesOverview.selected_stage.name
	theme = AssetManager.load_theme(Theme.new())
	
	Board.board_size = StagesOverview.selected_stage.size
	_cell_container.columns = Board.board_size.x
	
	Board.saved_time = 0.0
	Board.started = false
	Board.mutable = false
	Board.frozen = false
	Board.board_3bv = -1
	Board.is_flagless = true
	
	Stats.untouchable = true
	
	_monsters_label.text = str(StagesOverview.selected_stage.monsters)
	_power_label.text = "%d-%d" % [StagesOverview.selected_stage.min_power, StagesOverview.selected_stage.max_power]
	
	for i in board_size.x * board_size.y:
		var cell := Cell.create()
		cell.board_position = Vector2i(i % Board.board_size.x, i / Board.board_size.x)
		_cell_container.add_child(cell)
	
	const FADE_DURATION := 1.0
	Foreground.fade_in(FADE_DURATION)


func lose(_source: Object) -> void:
	Board.mutable = false
	Board.frozen = true


## Starts the board on the given [code]cell[/code]. Moves all mines in or nearby the cell away if present.
static func start_board(cell: Cell) -> void:
	assert(not Board.started, "Board has already started.")
	
	for i in Minesweeper.generate_mines(board_size, StagesOverview.selected_stage.monsters, cell.board_position, rng):
		var monster_cell := get_cell_at_index(i)
		monster_cell.cell_object = CellMonster.new(monster_cell)
	
	for any_cell in Board.get_cells():
		any_cell.reset_value()
	
	calculate_3bv()
	
	Board.start_time = Time.get_ticks_usec()
	
	Board.started = true
	Board.mutable = true


## Calculates the Board's 3BV value. This is called at the start of a stage, when it has just been generated.
## The value affects the amount of XP (and score) the player gets on completion.
static func calculate_3bv() -> void:
	var empty_groups: Array[Cell] = []
	board_3bv = 0
	
	for cell in get_cells():
		if cell.has_monster():
			continue
		if cell.cell_value == 0:
			if cell in empty_groups:
				continue
			
			board_3bv += 1
			
			empty_groups.append_array(cell.get_group())
		else:
			board_3bv += 1


## Checks for completion. If all cells without a monster have been revealed, shows the finish button and flags all hidden cells.
static func check_completion() -> void:
	var unsolved := 0
	for cell in Board.get_cells():
		if not cell.revealed and not cell.has_monster():
			unsolved += 1
	
	if unsolved <= (Board.board_size.x * Board.board_size.y - StagesOverview.selected_stage.monsters) * PlayerStats.pathfinding / 100.0:
		Board.mutable = false
		
		_instance._finish_button.show()
		
		for cell in Board.get_cells():
			if not cell.revealed:
				if cell.has_monster():
					cell.flag()
				else:
					cell.unflag()
					cell.open()


static func get_reward_types() -> PackedStringArray:
	var types := PackedStringArray(["victory"])
	
	if is_flagless:
		types.append("flagless")
	
	if Stats.untouchable:
		types.append("untouchable")
	
	var thrifty_count := 0
	for stage in Quest.stages:
		if stage == StagesOverview.selected_stage:
			break
		if stage is SpecialStage:
			if thrifty_count > 1:
				types.append("thrifty")
			thrifty_count += 1
	
	for cell in get_cells():
		if not "charitable" in types and cell.cell_object and cell.cell_object.is_charitable():
			types.append("charitable")
		if not "heartless" in types and cell.cell_object and cell.cell_object is CellHeart:
			types.append("heartless")
	
	if Quest.stages.all(func(a: Stage): return a.completed or a is SpecialStage):
		types.append("quest_complete")
	
	return types


static func update_monster_count() -> void:
	var monsters := 0
	
	for cell in get_cells():
		if cell.has_monster() and not cell.revealed:
			monsters += 1
		if cell.is_flagged():
			monsters -= 1
	
	_instance._monsters_label.text = str(monsters)


static func tween_texture(texture: Texture2D, start_pos: Vector2, end_pos: Vector2, duration: float, sprite_material: ShaderMaterial = null) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.scale = StageCamera.get_zoom_level()
	
	sprite.texture = texture
	sprite.material = sprite_material
	
	_instance._tweener_canvas.add_child(sprite)
	
	var tween := sprite.create_tween()
	tween.tween_property(sprite, "position", end_pos, duration).from(start_pos)
	tween.tween_callback(sprite.queue_free)
	return sprite


## [b]Not implemented.[/b] Returns whether the player must make a guess to proceed.
static func needs_guess() -> bool:
	return get_progress_cell() == null


## [b]Partially implemented [i](only trivial progress is detected)[/i].[/b]
## Returns a [Cell] where the player can make progress without guessing.
## Returns [code]null[/code] if no such [Cell] could be found.
static func get_progress_cell() -> Cell:
	var real_flags: Array[Cell] = []
	
	for cell in get_cells():
		if not cell.revealed or cell.cell_value == 0 or cell.cell_object:
			continue
		
		var hidden_cells := 0
		for neighbor in cell.get_nearby_cells():
			if not neighbor.revealed or neighbor.has_monster():
				hidden_cells += 1
		if hidden_cells == cell.cell_value:
			for neighbor in cell.get_nearby_cells():
				if neighbor.revealed:
					continue
				if not neighbor.is_flagged():
					return neighbor
				if not neighbor in real_flags:
					real_flags.append(neighbor)
	
	for cell in get_cells():
		if not cell.revealed or cell.cell_value == 0:
			continue
		
		var monsters := 0
		for neighbor in cell.get_nearby_cells():
			if neighbor in real_flags:
				monsters += 1
		if monsters == cell.cell_value:
			for neighbor in cell.get_nearby_cells():
				if neighbor.revealed:
					continue
				if not neighbor in real_flags:
					return neighbor
	
	return null


## [b]Not implemented[/b]. Solves a random cell, flagging it if it has a monster or unflagging it if not.
static func solve_cell() -> void:
	pass


## Returns the cell at the given map position. Returns [code]null[/code] if the cell does not exist.
static func get_cell(at: Vector2i) -> Cell:
	if at.x < 0 or at.y < 0 or at.x >= Board.board_size.x or at.y >= Board.board_size.y:
		return null
	return get_cell_at_index(at.x + at.y * board_size.x)


## Returns all cells in the current [Board].
static func get_cells() -> Array[Cell]:
	var cells: Array[Cell] = []
	cells.assign(_instance._cell_container.get_children())
	return cells


## Returns the cell at the given [code]index[/code].
static func get_cell_at_index(index: int) -> Cell:
	return _instance._cell_container.get_child(index)


## Returns the current stage time in seconds, as a [float]. The time shown to the player is an [int],
## so using [method get_time] is usually preferred.
static func get_timef() -> float:
	if Board.start_time < 0:
		return Board.saved_time
	
	return (Time.get_ticks_usec() - Board.start_time) / 1e6 + Board.saved_time


## Returns the current stage time in seconds, as an [int]. Use [method get_timef] to get a more precise time.
static func get_time() -> int:
	return int(get_timef())


func _on_finish_button_pressed() -> void:
	_animation_player.play("finish_show")
	_finish_button.hide()
	
	await _finish_popup_contents.finished
	
	_animation_player.play("finish_hide")
	
	await _animation_player.animation_finished
	
	for cell in Board.get_cells():
		cell.hide()
	
	Quest.unlock_next_stage(StagesOverview.selected_stage, true)
	StagesOverview.selected_stage.completed = true
	
	const FADE_DURATION := 1.0
	Foreground.fade_out_in(FADE_DURATION)
	_animation_player.play("board_exit")
	await _animation_player.animation_finished
	#await create_tween().tween_property(_background, "scale", Vector2.ONE * 4, FADE_DURATION).set_trans(Tween.TRANS_QUAD).finished
	
	if Quest.stages.all(func(stage: Stage): return stage.completed or stage is SpecialStage):
		Quest.finish()
		SavesManager.save()
		get_tree().change_scene_to_file("res://Scenes/QuestSelect/QuestSelect.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/StageSelect/StageSelect.tscn")


func _exit_tree() -> void:
	Board.started = false
	Board.saved_time = 0.0
