@tool
extends Resource
class_name StageInstance

# ==============================================================================
@export var cells: Array[CellData] = [] :
	set(value):
		cells = value
		if Engine.is_editor_hint() and get_stage() and value.size() > get_stage().area():
			value.resize(get_stage().area())
		emit_changed()
# ==============================================================================
@export var _stage: Stage : set = set_stage, get = get_stage
@export var _time := 0.0 : get = get_timef

@export var _3bv := 0 : get = get_3bv
@export var _timer_paused := true : get = is_timer_paused

@export var _generated := false : get = is_generated
@export var _flagless := true : get = is_flagless
@export var _untouchable := true : get = is_untouchable
# ==============================================================================
var _scene: StageScene : get = get_scene

var _timer_last_read_usec := 0
var _timer_read_on_this_frame := false :
	set(value):
		_timer_read_on_this_frame = value
		if value:
			await Promise.defer()
			_timer_read_on_this_frame = false
# ==============================================================================

func _bind_idx(idx: int) -> int:
	if idx < 0:
		idx += get_stage().area()
	return idx


func _stage_changed() -> void:
	if get_stage():
		if cells.size() > get_stage().area():
			cells.resize(get_stage().area())
		while cells.size() < get_stage().area():
			var data := CellData.new()
			data.changed.connect(func() -> void:
				emit_changed()
			)
			cells.append(data)
	
	emit_changed()


## Generates this [StageInstance], spawning [Monster]s at random [Cell]s.
## [br][br]Cells horizontally or diagonally adjacent to [code]start_cell[/code] will
## not contain a monster.
func generate(start_cell: CellData) -> void:
	const COORD_OFFSETS: PackedInt32Array = [-1, 0, 1]
	
	assert(not is_generated(), "Cannot generate a StageInstance that has already generated.")
	
	var invalid_indices := PackedInt32Array()
	for dy in COORD_OFFSETS:
		for dx in COORD_OFFSETS:
			var neighbor := start_cell.get_position(self) + Vector2i(dx, dy)
			if get_stage().has_coord(neighbor):
				invalid_indices.append(neighbor.x + neighbor.y * get_stage().size.x)
	
	assert(Array(invalid_indices).all(func(b: int) -> bool: return Array(invalid_indices.slice(0, invalid_indices.find(b))).all(func(a: int) -> bool: return a < b)))
	
	for i in get_stage().monsters:
		var idx := randi_range(0, get_stage().area() - invalid_indices.size() - 1)
		for j in invalid_indices:
			if j <= idx:
				idx += 1
		
		assert(idx not in invalid_indices)
		
		invalid_indices.insert(invalid_indices.bsearch(idx), idx)
		
		var coord := Vector2i(idx % get_stage().size.x, idx / get_stage().size.x)
		
		cells[idx].object = Monster.new(get_stage())
		
		for dx in COORD_OFFSETS:
			for dy in COORD_OFFSETS:
				if dx == 0 and dy == 0:
					continue
				if not get_stage().has_coord(coord + Vector2i(dx, dy)):
					continue
				cells[idx + dx + dy * get_stage().size.x].value += 1
	
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
	
	var table := load("res://Assets/loot_tables/CellContent.tres").generate() as LootTable
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


# TODO
func needs_guess() -> bool:
	return false


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
			
			empty_groups.append_array(cell.get_group(self))
		else:
			_3bv += 1
	
	return _3bv


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
	if stage and stage.changed.is_connected(_stage_changed):
		stage.changed.disconnect(_stage_changed)
	
	_stage = stage
	
	if stage:
		stage.changed.connect(_stage_changed)
	
	_stage_changed()


func get_stage() -> Stage:
	return _stage


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
