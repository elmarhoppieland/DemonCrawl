@tool
extends Resource
class_name StageInstance

# ==============================================================================
static var _current: StageInstance = Eternal.create(null) : set = _set_current, get = get_current

static var current_changed := Signal() :
	get:
		if current_changed.is_null():
			(StageInstance as GDScript).add_user_signal("_current_changed")
			current_changed = Signal(StageInstance, "_current_changed")
		return current_changed
# ==============================================================================
@export var cells: Array[CellData] = [] :
	set(value):
		cells = value
		if Engine.is_editor_hint() and get_stage() and value.size() > get_stage().area():
			value.resize(get_stage().area())
		for cell in value:
			cell.changed.connect(emit_changed)
		emit_changed()
# ==============================================================================
@export var _stage: Stage : set = set_stage, get = get_stage
@export var _time := 0.0 : get = get_timef

@export var _3bv := 0 : get = get_3bv
@export var _timer_paused := true : get = is_timer_paused

@export var _generated := false : get = is_generated
@export var _flagless := true : get = is_flagless
@export var _untouchable := true : get = is_untouchable

@export var _projectile_manager := ProjectileManager.new() : get = get_projectile_manager
# ==============================================================================
var _scene: StageScene : get = get_scene

var _stage_weakref: WeakRef = null

var _timer_last_read_usec := 0
var _timer_read_on_this_frame := false :
	set(value):
		_timer_read_on_this_frame = value
		if value:
			await Promise.defer()
			_timer_read_on_this_frame = false
# ==============================================================================
signal finish_pressed()
signal finished()
# ==============================================================================

#region internals

func _init(stage: Stage = null) -> void:
	load_from_stage(stage)


func _bind_idx(idx: int) -> int:
	if idx < 0:
		idx += get_stage().area()
	return idx


func _stage_changed() -> void:
	if Engine.is_editor_hint() and get_stage():
		if cells.size() > get_stage().area():
			cells.resize(get_stage().area())
		while cells.size() < get_stage().area():
			var data := CellData.new()
			data.changed.connect(emit_changed) # we CANNOT use a lambda function here - it causes a cyclic reference while a direct connection does not
			cells.append(data)
	
	emit_changed()

#endregion

static func _set_current(value: StageInstance) -> void:
	var different := _current != value
	_current = value
	if different:
		current_changed.emit()


static func get_current() -> StageInstance:
	return _current


static func has_current() -> bool:
	return get_current() != null


static func clear_current() -> void:
	_current = null


func set_as_current() -> void:
	_current = self


## Generates this [StageInstance], spawning [Monster]s at random [Cell]s.
## [br][br]Cells orthogonally or diagonally adjacent to [code]start_cell[/code] will
## not contain a monster.
func generate(start_cell: CellData) -> void:
	const COORD_OFFSETS: PackedInt32Array = [-1, 0, 1]
	
	assert(not is_generated(), "Cannot generate a StageInstance that has already generated.")
	
	var invalid_indices := PackedInt32Array()
	for dy in COORD_OFFSETS:
		for dx in COORD_OFFSETS:
			var neighbor := start_cell.get_position() + Vector2i(dx, dy)
			if get_stage().has_coord(neighbor):
				invalid_indices.append(neighbor.x + neighbor.y * get_stage().size.x)
	
	assert(Array(invalid_indices).all(func(b: int) -> bool: return Array(invalid_indices.slice(0, invalid_indices.find(b))).all(func(a: int) -> bool: return a < b)), "The invalid indices list is expected to be sorted.")
	
	for i in get_stage().monsters:
		var idx := randi_range(0, get_stage().area() - invalid_indices.size() - 1)
		for j in invalid_indices:
			if j <= idx:
				idx += 1
		
		assert(idx not in invalid_indices)
		
		invalid_indices.insert(invalid_indices.bsearch(idx), idx)
		
		cells[idx].object = Monster.new(get_stage())
	
	_generated = true
	
	_after_generating()


func _after_generating() -> void:
	_3bv = get_3bv()
	set_timer_paused(false)


## Creates and returns a new [Cell] for the [CellData] at the given [code]idx[/code].
func create_cell(idx: int) -> Cell:
	var data := get_cell_data(idx)
	if not data:
		return null
	
	var cell := Cell.create(Vector2i(idx % get_stage().size.x, idx / get_stage().size.x))
	cell.set_data(data)
	return cell


func finish() -> void:
	for cell in cells:
		if cell.object:
			cell.object.reset()
	finished.emit()


func get_cell_content_spawn_rate() -> float:
	const BASE_PROB := 0.3
	const MOD_FACTOR := 0.13
	const DENSITY_FACTOR := 0.5
	return 1 - (1 - BASE_PROB) * exp(-MOD_FACTOR * get_stage().get_mods_difficulty()) * (1 - get_stage().get_density()) ** DENSITY_FACTOR


func get_cell_content_quality(rare_loot_modifier: float = 1.0) -> float:
	if get_stage().monsters == get_stage().area():
		# this probably shouldn't happen since we wouldn't have space to spawn loot,
		# but let's allow it anyway
		return INF
	
	const MOD_FACTOR := 3.0
	return rare_loot_modifier * (1 + get_stage().get_mods_difficulty() / MOD_FACTOR) / (1 - get_stage().get_density())


func generate_cell_content(rare_loot_modifier: float = 1.0) -> CellObjectBase:
	if randf() > get_cell_content_spawn_rate():
		return null
	
	var table := load("res://Assets/LootTables/CellContent.tres").generate() as LootTable
	if not table:
		return
	
	var quality := get_cell_content_quality(rare_loot_modifier)
	var content: CellObjectBase = table.generate(quality)
	var i := 0
	while not content or not content.can_spawn():
		if i > 100:
			Debug.log_error("LootTable '%s' could not generate a cell's content." % table.resource_path)
			return null
		i += 1
		
		content = table.generate(quality)
	
	return content


## Returns all reward types if the [StageInstance] would be finished now.
func get_reward_types() -> PackedStringArray:
	var types := PackedStringArray(["victory"])
	
	if is_flagless():
		types.append("flagless")
	
	if is_untouchable():
		types.append("untouchable")
	
	var thrifty_count := 0
	for i in Quest.get_current().stages:
		if i == get_stage():
			break
		if i is SpecialStage:
			thrifty_count += 1
			if thrifty_count >= 3:
				types.append("thrifty")
				break
	
	for cell in get_stage().get_board().get_cells():
		if not "charitable" in types and cell.get_object() and cell.get_object().is_charitable():
			types.append("charitable")
		if not "heartless" in types and cell.get_object() and cell.get_object() is Heart:
			types.append("heartless")
	
	if Quest.get_current().stages.all(func(a: Stage) -> bool: return a.completed or a is SpecialStage):
		types.append("quest_complete")
	
	return types


## Returns the [CellData] for the given index.
## [br][br]If the index is negative, reads from the end of the [Array].
func get_cell_data(idx: int) -> CellData:
	idx = _bind_idx(idx)
	if idx < 0 or idx >= get_stage().area():
		return null
	
	assert(cells.size() == get_stage().area())
	
	var data := cells[idx]
	return data


## Returns the [CellData] at the given position.
## [br][br][Cell]s automatically update if their [CellData] object is changed, so
## so this can often be used instead of using the [Cell] directly.
func get_cell(at: Vector2i) -> CellData:
	if at.x < 0 or at.y < 0:
		return null
	if at.x >= get_stage().size.x or at.y >= get_stage().size.y:
		return null
	
	return cells[at.x + at.y * get_stage().size.x]


## Returns an [Array] of all [Cell]s in the [Stage].
func get_cells() -> Array[CellData]:
	return cells


## Returns the [CellObject] of the [Cell] at the given index. Returns [code]null[/code]
## if the index is invalid.
func get_object(idx: int) -> CellObject:
	var data := get_cell_data(idx)
	return data.object if data else null


## Returns the value of the [Cell] at the given index. Returns [code]-1[/code]
## if the index is invalid.
func get_value(idx: int) -> int:
	var data := get_cell_data(idx)
	return data.value if data else -1


## Returns the mode of the [Cell] at the given index. Returns [constant Cell.INVALID]
## if the index is invalid.
func get_mode(idx: int) -> Cell.Mode:
	var data := get_cell_data(idx)
	return data.mode if data else Cell.Mode.INVALID


## Returns whether the get_stage() is finished, i.e. all non-monster [Cell]s are revealed.
func is_finished() -> bool:
	for data in cells:
		if data.mode != Cell.Mode.VISIBLE and not data.object is Monster:
			return false
	
	return true


func needs_guess() -> bool:
	return get_progress_cell() == null


func get_progress_cell() -> CellData:
	var real_flags: Array[CellData] = []
	
	for cell in get_cells():
		if cell.is_hidden() or cell.value == 0 or cell.is_occupied():
			continue
		
		var hidden_cells: Array[CellData] = []
		for neighbor in cell.get_nearby_cells():
			if neighbor.is_hidden() or neighbor.object is Monster:
				hidden_cells.append(neighbor)
		if hidden_cells.size() == cell.value:
			for neighbor in hidden_cells:
				if neighbor not in real_flags:
					real_flags.append(neighbor)
	
	for cell in get_cells():
		if cell.is_hidden() or cell.is_occupied():
			continue
		
		var monsters := 0
		var safe_cell: CellData = null
		for neighbor in cell.get_nearby_cells():
			if neighbor in real_flags:
				monsters += 1
			elif not safe_cell and neighbor.is_hidden():
				safe_cell = neighbor
		if safe_cell and monsters == cell.value:
			return safe_cell
	
	return null


func get_3bv() -> int:
	if _3bv:
		return _3bv
	
	var empty_groups: Array[CellData] = []
	
	for cell in get_cells():
		if cell.object is Monster:
			continue
		if cell.value == 0:
			if cell in empty_groups:
				continue
			
			_3bv += 1
			
			empty_groups.append_array(cell.get_group())
		else:
			_3bv += 1
	
	return _3bv


func solve_cell() -> CellData:
	var unsolved_cells := get_cells().filter(func(cell: CellData) -> bool:
		return cell.is_hidden() and cell.is_flagged() != cell.object is Monster
	)
	if unsolved_cells.is_empty():
		return null
	
	var cell := unsolved_cells.pick_random() as CellData
	
	if cell.is_flagged():
		cell.unflag()
	else:
		cell.flag()
	
	return cell


## Returns whether this [StageInstance] has been generated. If this is not the
## case, [method get_cell] will return the correct instances of [CellData],
## but their properties may be changed when the first [Cell] gets opened.
func is_generated() -> bool:
	return _generated


## Removes flagless from this [StageInstance]. This should be called when a [Cell]
## has been manually flagged.
func remove_flagless() -> void:
	_flagless = false


## Returns whether this [StageInstance] has been solved flagless so far, i.e.
## no [Cell] has ever been flagged manually (or: [method remove_flagless] has never
## been called).
func is_flagless() -> bool:
	return _flagless


## Returns whether this [Stage] has been solved without taking damage so far.
func is_untouchable() -> bool:
	return _untouchable


func get_remaining_monster_count() -> int:
	if not is_generated():
		return get_stage().monsters
	
	var monsters := 0
	
	for cell in get_cells():
		if cell.object is Monster and cell.is_hidden():
			monsters += 1
		if cell.is_flagged():
			monsters -= 1
	
	return monsters


func set_stage(stage: Stage) -> void:
	if _stage and _stage.changed.is_connected(_stage_changed):
		_stage.changed.disconnect(_stage_changed)
	
	_stage_weakref = weakref(stage)
	
	if stage:
		stage.changed.connect(_stage_changed)


func load_from_stage(stage: Stage) -> void:
	set_stage(stage)
	
	if stage == null:
		return
	
	if stage:
		if cells.size() > stage.area():
			cells.resize(stage.area())
		while cells.size() < stage.area():
			var data := CellData.new()
			data.set_stage_instance(self)
			data.changed.connect(emit_changed) # we CANNOT use a lambda function here - it causes a cyclic reference while a direct connection does not
			cells.append(data)
	
	emit_changed()


func get_stage() -> Stage:
	if _stage_weakref == null:
		return null
	return _stage_weakref.get_ref()


func get_time() -> int:
	return int(get_timef())


func get_timef() -> float:
	if is_timer_paused() or _timer_read_on_this_frame:
		return _time
	
	var time := Time.get_ticks_usec()
	_time += (time - _timer_last_read_usec) / 1e6
	_timer_last_read_usec = time
	_timer_read_on_this_frame = true
	
	return _time


func set_timer_paused(timer_paused: bool) -> void:
	_timer_paused = timer_paused
	if not timer_paused:
		_timer_last_read_usec = Time.get_ticks_usec()


func is_timer_paused() -> bool:
	return _timer_paused


## Returns the currently active [StageScene].
func get_scene() -> StageScene:
	if is_instance_valid(_scene):
		return _scene
	
	var loop := Engine.get_main_loop()
	assert(loop is SceneTree, "Expected a SceneTree as the main loop, but a %s was found." % loop.get_class())
	
	var current_scene := (loop as SceneTree).current_scene
	if current_scene is StageScene:
		_scene = current_scene
	
	return _scene


func has_scene() -> bool:
	return _scene != null


func get_board() -> Board:
	return get_scene().get_board()


func get_projectile_manager() -> ProjectileManager:
	return _projectile_manager
