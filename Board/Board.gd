extends Control
class_name Board

## The Minesweeper board.
## 
## The board that contains all cells.
## [br][br][b]Note:[/b] All non-private properties and methods are static and should be called on
## the class, for example:
## [codeblock]
## Board.get_cell(Vector2i(3, 8))
## [/codeblock]

# ==============================================================================
enum State {
	UNINITIALIZED,
	RUNNING,
	FROZEN,
	FINISHED
}
enum Permission {
	OPEN_CELL = 0b001, ## Cells can be opened.
	FLAG_CELL = 0b010, ## Cells can be flagged.
	RUN_TIMER = 0b100, ## The timer can run. Can be overridden by [method pause_timer] or [method resume_timer]. Use [method is_timer_running] to check if the timer is running.
}
# ==============================================================================
const CELL_SIZE := Vector2i(16, 16)
# ==============================================================================
static var _instance: Board :
	get:
		assert(_unsafe_access or is_instance_valid(_instance), "Attempted to use the Board instance when it has not been instantiated.")
		return _instance
static var _unsafe_access := false

static var rng := RandomNumberGenerator.new() ## The [RandomNumberGenerator] used to generate boards. Use [member RandomNumberGenerator.seed] to make boards generate consistently.

static var board_size: Vector2i = Eternal.create(Vector2i.ZERO) ## The number of cells in each row and column.

static var start_time := -1 ## The amount of ticks (microseconds) since game launch when the timer started running.
static var saved_time: float = Eternal.create(0.0) ## The timer when it was loaded.

static var board_3bv: int = Eternal.create(-1) ## The board's 3BV value.
static var is_flagless: bool = Eternal.create(true) ## Whether the board is flagless up to this point.

static var state: State = Eternal.create(State.UNINITIALIZED) :
	set(value):
		state = value
		
		_permissions = -1
		
		if get_permissions() & Permission.RUN_TIMER:
			resume_timer()
		else:
			pause_timer()
		
		EffectManager.propagate_call("board_permissions_changed")
static var _permissions := -1
# ==============================================================================
@onready var _finish_button: MarginContainer = %FinishButton
@onready var _monsters_label: Label = %MonstersLabel
@onready var _power_label: Label = %PowerLabel
@onready var _cell_container: GridContainer = %CellContainer
@onready var _finish_popup_contents: FinishPopupContents = %FinishPopupContents
@onready var _tweener_canvas: CanvasLayer = %TweenerCanvas
@onready var _animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================

func _enter_tree() -> void:
	_instance = self
	
	EffectManager.connect_effect(lose)


func _ready() -> void:
	EffectManager.propagate_call("stage_enter")
	
	Inventory.gain_item(Item.from_path("Apple"))
	Inventory.gain_item(Item.from_path("Minion"))
	Inventory.gain_item(Item.from_path("Sleeping Powder"))
	
	AssetManager.theme = StagesOverview.selected_stage.name
	theme = AssetManager.load_theme(Theme.new())
	
	Board.board_size = StagesOverview.selected_stage.size
	_cell_container.columns = Board.board_size.x
	
	Board.saved_time = 0.0
	Board.state = State.UNINITIALIZED
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
	Board.state = State.FROZEN
	Board.pause_timer()


## Starts the board on the given [code]cell[/code]. Moves all mines in or nearby the cell away if present.
static func start_board(cell: Cell) -> void:
	assert(Board.state == State.UNINITIALIZED, "Board has already started.")
	
	for i in Minesweeper.generate_mines(board_size, StagesOverview.selected_stage.monsters, cell.board_position, rng):
		var monster_cell := get_cell_at_index(i)
		monster_cell.cell_object = CellMonster.new(monster_cell)
	
	for any_cell in Board.get_cells():
		any_cell.reset_value()
	
	calculate_3bv()
	
	Board.start_time = Time.get_ticks_usec()
	
	Board.state = State.RUNNING
	
	EffectManager.propagate_call("board_begin")
	EffectManager.propagate_call("stage_load")


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
		Board.state = State.FINISHED
		
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
			thrifty_count += 1
			if thrifty_count >= 3:
				types.append("thrifty")
				break
	
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


## Solves a random cell, flagging it if it has a monster or unflagging it if not.
static func solve_cell() -> void:
	var cells := get_cells().filter(func(cell: Cell):
		return not cell.revealed and cell.has_monster() != cell.is_flagged()
	)
	
	if cells.is_empty():
		return
	
	var cell_to_solve: Cell = cells[RNG.randi(rng) % cells.size()]
	
	if cell_to_solve.has_monster():
		cell_to_solve.flag(false)
	else:
		cell_to_solve.unflag()


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


## Pauses the timer.
static func pause_timer() -> void:
	if Board.start_time < 0:
		return
	
	Board.saved_time = Board.get_timef()
	Board.start_time = -1


## Resumes the timer.
static func resume_timer() -> void:
	if Board.start_time < 0:
		Board.start_time = Time.get_ticks_usec()


## Returns whether the timer is currently paused.
static func is_timer_paused() -> bool:
	return Board.start_time < 0


## Returns the current stage time in seconds, as a [float]. The time shown to the player is an [int],
## so using [method get_time] is usually preferred.
static func get_timef() -> float:
	if Board.start_time < 0:
		return Board.saved_time
	
	return (Time.get_ticks_usec() - Board.start_time) / 1e6 + Board.saved_time


## Returns the current stage time in seconds, as an [int]. Use [method get_timef] to get a more precise time.
static func get_time() -> int:
	return int(get_timef())


## Returns whether the board exists. This should [b]always[/b] be called when accessing
## the Board when it may not exist. Calling methods that need the instance when it
## does not exist results in an error if running in the editor.
static func exists() -> bool:
	_unsafe_access = true
	var instance_exists := is_instance_valid(_instance)
	_unsafe_access = false
	return instance_exists


## Returns the board's permissions as a bitfield of [enum Permission].
static func get_permissions() -> int:
	if _permissions >= 0:
		return _permissions
	
	var default := 0
	
	match state:
		State.UNINITIALIZED:
			default = Permission.OPEN_CELL
		State.RUNNING:
			default = Permission.OPEN_CELL | Permission.FLAG_CELL | Permission.RUN_TIMER
		State.FROZEN:
			default = Permission.RUN_TIMER
		State.FINISHED:
			default = Permission.OPEN_CELL
	
	_permissions = EffectManager.propagate_posnum("get_board_permissions", [state], default)
	return _permissions


## Returns whether cells can be opened.
static func can_open_cells() -> bool:
	return get_permissions() & Permission.OPEN_CELL


## Returns whether cells can be flagged.
static func can_flag_cells() -> bool:
	return get_permissions() & Permission.FLAG_CELL


## Returns whether the timer can run. Can be overridden by [method pause_timer]
## and/or [method resume_timer]. Use [method is_timer_running] to check if the
## timer is running.
## [br][br]Status effects also use this permission, so this can be used to check
## if time-based status effects should advance.
static func can_run_timer() -> bool:
	return get_permissions() & Permission.RUN_TIMER


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
		Eternity.save()
		get_tree().change_scene_to_file("res://Scenes/QuestSelect/QuestSelect.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/StageSelect/StageSelect.tscn")


func _exit_tree() -> void:
	Board.state = State.UNINITIALIZED
	Board.saved_time = 0.0
