@tool
extends Node
class_name StageInstance

# ==============================================================================
#static var _current: StageInstance = Eternal.create(null) : set = _set_current, get = get_current

#static var current_changed := Signal() :
	#get:
		#if current_changed.is_null():
			#(StageInstance as GDScript).add_user_signal("_current_changed")
			#current_changed = Signal(StageInstance, "_current_changed")
		#return current_changed
# ==============================================================================
#@export var cells: Array[CellData] = [] :
	#set(value):
		#cells = value
		#if Engine.is_editor_hint() and get_stage() and value.size() > get_stage().area():
			#value.resize(get_stage().area())
		#for cell in value:
			#cell.changed.connect(emit_changed)
		#emit_changed()
# ==============================================================================
@export var _3bv := 0 : get = get_3bv

@export var _generated := false : get = is_generated
@export var _flagless := true : get = is_flagless
@export var _untouchable := true : get = is_untouchable

#@export var _timer: StageTimer = null : get = get_timer
#@export var _status_timer: StageTimer = null : get = get_status_timer

#@export var _projectile_manager: ProjectileManager = null : get = get_projectile_manager
# ==============================================================================
var _scene: StageScene : get = get_scene

var _effects := StageEffects.new() : get = get_effects
var _immunity := Immunity.create_immunity_list() : get = get_immunity
# ==============================================================================
signal finish_pressed()
signal finished()

#signal loaded()
#signal unloaded()

signal changed()
# ==============================================================================

func _ready() -> void:
	if Eternity.get_processing_file() != null:
		await Eternity.get_processing_file().loaded
		if not is_generated():
			get_timer().pause()
			get_status_timer().pause()
		
		check_completed()
		return
	
	var stage := get_stage()
	
	for i in stage.area():
		var data := CellData.new()
		data.changed.connect(emit_changed)
		get_grid().add_child(data)
	
	get_timer().pause()
	get_status_timer().pause()
	
	emit_changed()


func emit_changed() -> void:
	changed.emit()

#region internals

func _bind_idx(idx: int) -> int:
	if idx < 0:
		idx += get_stage().area()
	return idx


#func _stage_changed() -> void:
	#if Engine.is_editor_hint() and get_stage():
		#if get_cells().size() > get_stage().area():
			#get_cells().resize(get_stage().area())
		#while get_cells().size() < get_stage().area():
			#var data := CellData.new()
			#data.changed.connect(emit_changed) # we CANNOT use a lambda function here - it causes a cyclic reference while a direct connection does not
			#cells.append(data)
	#
	#emit_changed()

#endregion

#static func _set_current(value: StageInstance) -> void:
	#var different := _current != value
	#_current = value
	#if different:
		#current_changed.emit()


#static func get_current() -> StageInstance:
	#return _current


#static func has_current() -> bool:
	#return get_current() != null


#static func clear_current() -> void:
	#_current = null


#func set_as_current() -> void:
	#_current = self


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
		
		get_cells()[idx].set_object(Monster.new(get_stage()))
	
	var objects: Array[CellObject] = EffectManager.propagate(get_effects().get_guaranteed_objects, [[] as Array[CellObject]], 0)
	var cells: Array[CellData] = []
	cells.assign(get_cells().filter(func(cell: CellData) -> bool: return cell.is_empty()))
	var picked := PackedInt32Array()
	for object in objects:
		var idx := randi() % (cells.size() - picked.size())
		for j in picked:
			if j <= idx:
				idx += 1
		
		picked.insert(picked.bsearch(idx), idx)
		
		cells[idx].set_object(object)
	
	EffectManager.propagate(get_effects().generated)
	
	_generated = true
	
	_after_generating()


func _after_generating() -> void:
	_3bv = get_3bv()
	
	get_timer().play()
	get_status_timer().play()


## Creates and returns a new [Cell] for the [CellData] at the given [code]idx[/code].
func create_cell(idx: int) -> Cell:
	var data := get_cell_data(idx)
	if not data:
		return null
	
	var cell := Cell.create(Vector2i(idx % get_stage().size.x, idx / get_stage().size.x))
	cell.set_data(data)
	return cell


func finish() -> void:
	get_stage().completed = true
	finished.emit()


#func notify_loaded() -> void:
	#loaded.emit()
	#
	## make sure the timers get loaded
	#var timer := get_timer()
	#var status_timer := get_status_timer()
	#if _generated:
		#timer.play()
		#status_timer.play()
	#else:
		#timer.pause()
		#status_timer.pause()


#func notify_unloaded() -> void:
	#unloaded.emit()
	#
	#get_timer().pause()
	#get_status_timer().pause()


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
	for i in Quest.get_current().get_stages():
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
	
	if Quest.get_current().get_stages().all(func(a: Stage) -> bool: return a.completed or a is SpecialStage):
		types.append("quest_complete")
	
	return types


## Returns the [CellData] for the given index.
## [br][br]If the index is negative, reads from the end of the [Array].
func get_cell_data(idx: int) -> CellData:
	idx = _bind_idx(idx)
	if idx < 0 or idx >= get_stage().area():
		return null
	
	assert(get_cells().size() == get_stage().area())
	
	var data := get_cells()[idx]
	return data


## Returns the [CellData] at the given position.
## [br][br][Cell]s automatically update if their [CellData] object is changed, so
## so this can often be used instead of using the [Cell] directly.
func get_cell(at: Vector2i) -> CellData:
	if at.x < 0 or at.y < 0:
		return null
	if at.x >= get_stage().size.x or at.y >= get_stage().size.y:
		return null
	
	return get_cells()[at.x + at.y * get_stage().size.x]


func get_grid() -> Node:
	if not has_node("Grid"):
		var grid := Grid.new()
		grid.name = "Grid"
		add_child(grid)
	
	return get_node("Grid")


## Returns an [Array] of all [Cell]s in the [Stage].
func get_cells() -> Array[CellData]:
	var cells: Array[CellData] = []
	cells.assign(get_grid().get_children())
	return cells


## Returns the [CellObject] of the [Cell] at the given index. Returns [code]null[/code]
## if the index is invalid.
#func get_object(idx: int) -> CellObject:
	#var data := get_cell_data(idx)
	#return data.get_object() if data else null


## Returns the value of the [Cell] at the given index. Returns [code]-1[/code]
## if the index is invalid.
#func get_value(idx: int) -> int:
	#var data := get_cell_data(idx)
	#return data.value if data else -1


## Returns the mode of the [Cell] at the given index. Returns [constant Cell.INVALID]
## if the index is invalid.
#func get_mode(idx: int) -> Cell.Mode:
	#var data := get_cell_data(idx)
	#return data.mode if data else Cell.Mode.INVALID


## Returns whether the get_stage() is finished, i.e. all non-monster [Cell]s are revealed.
func is_completed() -> bool:
	for cell in get_cells():
		if cell.is_hidden() and not cell.has_monster():
			return false
	
	return true


func check_completed() -> void:
	if is_completed():
		for cell in get_cells():
			if cell.has_monster():
				cell.flag()
			else:
				cell.open(true)
		EffectManager.propagate(get_effects().completed)


func needs_guess() -> bool:
	return get_progress_cell() == null


func get_progress_cell() -> CellData:
	var real_flags: Array[CellData] = []
	
	for cell in get_cells():
		if cell.is_hidden() or cell.value == 0 or cell.is_occupied():
			continue
		
		var hidden_cells: Array[CellData] = []
		for neighbor in cell.get_nearby_cells():
			if neighbor.is_hidden() or neighbor.has_monster():
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
		if cell.has_monster():
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
		return cell.is_hidden() and cell.is_flagged() != cell.has_monster()
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
		if cell.has_monster() and cell.is_hidden():
			monsters += 1
		if cell.is_flagged():
			monsters -= 1
	
	return monsters


func get_stage() -> Stage:
	return get_parent()


func get_quest() -> Quest:
	var base := get_parent()
	while base != null and base is not Quest:
		base = base.get_parent()
	return base


func was_reloaded() -> bool:
	return false # TODO


func get_time() -> int:
	return get_timer().get_time()


func get_timef() -> float:
	return get_timer().get_timef()


func is_timer_paused() -> bool:
	return get_timer().is_paused()


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


func change_to_scene() -> StageScene:
	return await SceneManager.change_scene_to_custom(create_scene)


func create_scene() -> StageScene:
	if _scene:
		return _scene
	
	_scene = load("res://Engine/Scenes/StageScene/StageScene.tscn").instantiate()
	_scene.stage_instance = self
	
	_scene.finish_pressed.connect(finish_pressed.emit)
	
	return _scene


func has_scene() -> bool:
	return _scene != null


func get_board() -> Board:
	return get_scene().get_board()


func get_timer() -> StageTimer:
	if not has_node("Timer"):
		var timer := StageTimer.new()
		timer.name = "Timer"
		add_child(timer)
		return timer
	return get_node("Timer")


func get_status_timer() -> StageTimer:
	if not has_node("StatusTimer"):
		var timer := StageTimer.new()
		timer.name = "StatusTimer"
		add_child(timer)
		return timer
	return get_node("StatusTimer")


func get_projectile_manager() -> ProjectileManager:
	for child in get_children():
		if child is ProjectileManager:
			return child
	
	var projectile_manager := ProjectileManager.new()
	add_child(projectile_manager)
	return projectile_manager


func get_effects() -> StageEffects:
	return _effects


func get_immunity() -> Immunity.ImmunityList:
	return _immunity


class Grid extends Node:
	func _export_children() -> Array[CellData]:
		var children: Array[CellData] = []
		children.assign(get_children())
		return children


class StageEffects:
	@warning_ignore("unused_signal") signal get_guaranteed_objects(objects: Array[CellObject])
	
	@warning_ignore("unused_signal") signal get_object_value(object: CellObject, value: int, value_name: StringName)
	@warning_ignore("unused_signal") signal handle_object_interact_failed(object: CellObject, handled: bool)
	@warning_ignore("unused_signal") signal object_interact_failed(object: CellObject, handled: bool)
	@warning_ignore("unused_signal") signal handle_object_second_interact_failed(object: CellObject, handled: bool)
	@warning_ignore("unused_signal") signal object_second_interact_failed(object: CellObject)
	
	@warning_ignore("unused_signal") signal turn()
	
	@warning_ignore("unused_signal") signal item_used_on_cell(item: Item, cell: CellData)
	@warning_ignore("unused_signal") signal item_activated(item: Item)
	
	@warning_ignore("unused_signal") signal cell_open(cell: CellData)
	@warning_ignore("unused_signal") signal cell_interacted(cell: CellData)
	@warning_ignore("unused_signal") signal cell_second_interacted(cell: CellData)
	@warning_ignore("unused_signal") signal cell_aura_applied(cell: CellData)
	@warning_ignore("unused_signal") signal cell_aura_removed(cell: CellData)
	
	@warning_ignore("unused_signal") signal object_revealed(object: CellObject, active: bool)
	@warning_ignore("unused_signal") signal object_killed(object: CellObject)
	@warning_ignore("unused_signal") signal object_interacted(object: CellObject)
	@warning_ignore("unused_signal") signal object_second_interacted(object: CellObject)
	
	@warning_ignore("unused_signal") signal object_used(object: CellObject)
	@warning_ignore("unused_signal") signal object_second_used(object: CellObject)
	
	@warning_ignore("unused_signal") signal mistake_made(cell: CellData)
	
	@warning_ignore("unused_signal") signal entered()
	@warning_ignore("unused_signal") signal generated()
	@warning_ignore("unused_signal") signal started()
	@warning_ignore("unused_signal") signal completed()
	@warning_ignore("unused_signal") signal finish_pressed()
	@warning_ignore("unused_signal") signal exited()
