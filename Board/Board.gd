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
	VOID,
	UNINITIALIZED,
	RUNNING,
	FROZEN,
	LOST,
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

static var _reloaded := false

static var rng := RandomNumberGenerator.new() ## The [RandomNumberGenerator] used to generate boards. Use [member RandomNumberGenerator.seed] to make boards generate consistently.

static var start_time := -1 ## The amount of ticks (microseconds) since game launch when the timer started running.
static var saved_time: float = Eternal.create(0.0) ## The timer when it was loaded.

static var board_3bv: int = Eternal.create(-1) ## The board's 3BV value.
static var is_flagless: bool = Eternal.create(true) ## Whether the board is flagless up to this point.

static var state: State = Eternal.create(State.VOID) :
	set(value):
		state = value
		
		_permissions = -1
		
		if get_permissions() & Permission.RUN_TIMER:
			resume_timer()
		else:
			pause_timer()
		
		EffectManager.propagate_call("board_permissions_changed")
static var _permissions := -1

#static var board: String = Eternal.create("")
static var board_values: PackedInt32Array = Eternal.create(PackedInt32Array())
static var board_cell_states: PackedByteArray = Eternal.create(PackedByteArray())
static var board_objects: Array[CellObject] = Eternal.create([] as Array[CellObject])
static var board_enchantments: Dictionary = Eternal.create({})

static var grid := GDPlus.Grid.new()
# ==============================================================================
@onready var _finish_button: MarginContainer = %FinishButton
@onready var _monsters_label: Label = %MonstersLabel
@onready var _power_label: Label = %PowerLabel
@onready var _stage_mods_container: HBoxContainer = %StageModsContainer
@onready var _cell_container: GridContainer = %CellContainer
@onready var _finish_popup_contents: FinishPopupContents = %FinishPopupContents
@onready var _tweener_canvas: CanvasLayer = %TweenerCanvas
@onready var _animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================

func _enter_tree() -> void:
	_instance = self
	
	EffectManager.connect_effect(player_lose, EffectManager.Priority.ENVIRONMENT, 0) # TODO: determine subpriority


func _ready() -> void:
	# DEBUG - should be removed once gaining items is more complete
	Inventory.gain_item(Item.from_path("Apple"))
	Inventory.gain_item(Item.from_path("Minion"))
	Inventory.gain_item(Item.from_path("Sleeping Powder"))
	
	_load_stage_mods()
	
	if Board.state == State.VOID:
		_reloaded = false
		
		EffectManager.propagate_call("stage_enter")
		
		Board.state = State.UNINITIALIZED
		
		_reset_internals()
		
		Stats.untouchable = true
		
		Board.notify_stage_changed()
		
		_init_cells()
		
		Foreground.fade_in()
	else:
		_reloaded = true
		
		Board.notify_stage_changed()
		
		_init_cells_from_saved()
		
		Foreground.fade_in(0.0)
	
	EffectManager.propagate_call("board_loaded")


func _load_stage_mods() -> void:
	for mod in Quest.get_selected_stage().mods:
		_stage_mods_container.add_child(mod.icon)
		EffectManager.register_object(mod, EffectManager.Priority.STAGE_MOD, 0) # TODO: determine subpriority


func _reset_theme() -> void:
	AssetManager.theme = Quest.get_selected_stage().name
	theme = AssetManager.load_theme(Theme.new())


func _reset_internals() -> void:
	Board.saved_time = 0.0
	Board.board_3bv = -1
	Board.is_flagless = true


func _init_cells() -> void:
	for i in grid.area():
		var cell := Cell.create()
		cell.board_position = grid.index_to_position(i)
		cell.set_hidden()
		_cell_container.add_child(cell)


func _init_cells_from_saved() -> void:
	for i in grid.area():
		var cell := Cell.create()
		cell.board_position = grid.index_to_position(i)
		
		cell.cell_value = board_values[i]
		
		var cell_state := board_cell_states[i] as Cell.State
		cell.set_state(cell_state as Cell.State)
		
		cell.cell_object = board_objects[i]
		
		if cell.board_position in board_enchantments:
			cell.enchants = board_enchantments[cell.board_position]
		
		_cell_container.add_child(cell)


func player_lose() -> void:
	Board.state = State.LOST


## Starts the board on the given [code]cell[/code]. Moves all mines in or nearby the cell away if present.
static func start_board(cell: Cell) -> void:
	assert(Board.state == State.UNINITIALIZED, "Board has already started.")
	
	for i in Minesweeper.generate_mines(grid.get_size(), Quest.get_selected_stage().monsters, cell.board_position, rng):
		var monster_cell := get_cell_at_index(i)
		monster_cell.cell_object = CellMonster.new(grid.index_to_position(i))
	
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
		if not cell.is_revealed() and not cell.has_monster():
			unsolved += 1
	
	if unsolved <= (grid.area() - Quest.get_selected_stage().monsters) * PlayerStats.pathfinding / 100.0:
		Board.state = State.FINISHED
		
		_instance._finish_button.show()
		
		for cell in Board.get_cells():
			if not cell.is_revealed():
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
	for i in Quest.stages.size():
		var stage := Quest.stages[i]
		if i == Quest.selected_stage_idx:
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


static func roll_power() -> int:
	return rng.randi_range(Quest.get_selected_stage().min_power, Quest.get_selected_stage().max_power)


static func update_monster_count() -> void:
	var monsters := 0
	
	for cell in get_cells():
		if cell.has_monster() and not cell.is_revealed():
			monsters += 1
		if cell.is_flagged():
			monsters -= 1
	
	_instance._monsters_label.text = str(monsters)


static func notify_stage_changed() -> void:
	_instance._monsters_label.text = str(Quest.get_selected_stage().monsters)
	_instance._power_label.text = "%d-%d" % [Quest.get_selected_stage().min_power, Quest.get_selected_stage().max_power]
	
	grid.set_grid_size(Quest.get_selected_stage().size)
	
	_instance._reset_theme()
	
	_instance._cell_container.columns = grid.get_width()


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
		if not cell.is_revealed() or cell.cell_value == 0 or cell.cell_object:
			continue
		
		var hidden_cells := 0
		for neighbor in cell.get_nearby_cells():
			if not neighbor.is_revealed() or neighbor.has_monster():
				hidden_cells += 1
		if hidden_cells == cell.cell_value:
			for neighbor in cell.get_nearby_cells():
				if neighbor.is_revealed():
					continue
				if not neighbor.is_flagged():
					return neighbor
				if not neighbor in real_flags:
					real_flags.append(neighbor)
	
	for cell in get_cells():
		if not cell.is_revealed() or cell.cell_value == 0:
			continue
		
		var monsters := 0
		for neighbor in cell.get_nearby_cells():
			if neighbor in real_flags:
				monsters += 1
		if monsters == cell.cell_value:
			for neighbor in cell.get_nearby_cells():
				if neighbor.is_revealed():
					continue
				if not neighbor in real_flags:
					return neighbor
	
	return null


## Solves a random cell, flagging it if it has a monster or unflagging it if not.
static func solve_cell() -> void:
	var cells := get_cells().filter(func(cell: Cell):
		return not cell.is_revealed() and cell.has_monster() != cell.is_flagged()
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
	if not grid.has(at):
		return null
	return get_cell_at_index(grid.position_to_index(at))


## Returns all cells in the current [Board].
static func get_cells() -> Array[Cell]:
	if not exists():
		return []
	
	var cells: Array[Cell] = []
	cells.assign(_instance._cell_container.get_children())
	return cells


## Returns the cell at the given [code]index[/code].
static func get_cell_at_index(index: int) -> Cell:
	if not grid.has_index(index):
		return null
	
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
	return has_instance() and Board.state != State.VOID


static func has_instance() -> bool:
	_unsafe_access = true
	var value := _instance != null
	_unsafe_access = false
	return value


static func was_reloaded() -> bool:
	return _reloaded


## Returns the board's permissions as a bitfield of [enum Permission].
static func get_permissions() -> int:
	if _permissions >= 0:
		return _permissions
	
	var default := 0
	
	match state:
		State.VOID:
			default = 0
		State.LOST:
			default = 0
		State.UNINITIALIZED:
			default = Permission.OPEN_CELL
		State.RUNNING:
			default = Permission.OPEN_CELL | Permission.FLAG_CELL | Permission.RUN_TIMER
		State.FROZEN:
			default = Permission.RUN_TIMER
		State.FINISHED:
			default = Permission.OPEN_CELL
	
	_permissions = EffectManager.propagate_posnum("get_board_permissions", default, [state])
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
	
	Quest.unlock_next_stage()
	Quest.get_selected_stage().completed = true
	
	const FADE_DURATION := 1.0
	Foreground.fade_out_in(FADE_DURATION)
	_animation_player.play("board_exit")
	await _animation_player.animation_finished
	
	EffectManager.propagate_call("stage_leave")
	
	if Quest.stages.all(func(stage: Stage): return stage.completed or stage is SpecialStage):
		Quest.finish()
		Eternity.save()
		get_tree().change_scene_to_file("res://Scenes/QuestSelect/QuestSelect.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/StageSelect/StageSelect.tscn")


func _exit_tree() -> void:
	Board.state = State.VOID
	Board.saved_time = 0.0


static func _export_board() -> String:
	return ",".join(get_cells().map(func(cell: Cell) -> String:
		return cell.serialize()
	))


static func _export_board_values() -> PackedInt32Array:
	return get_cells().map(func(cell: Cell) -> int:
		return cell.cell_value
	)


static func _export_board_cell_states() -> PackedByteArray:
	return get_cells().map(func(cell: Cell) -> int:
		return cell.state
	)


static func _export_board_objects() -> Array[CellObject]:
	if not exists():
		return []
	
	var value: Array[CellObject] = []
	value.assign(get_cells().map(func(cell: Cell) -> CellObject:
		return cell.cell_object
	))
	return value


static func _export_board_enchantments() -> Dictionary:
	if not exists():
		return {}
	
	var value := {}
	
	for cell in get_cells():
		if not cell.enchants.is_empty():
			value[cell.board_position] = cell.enchants
	
	return value
