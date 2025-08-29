@tool
extends Node
class_name CellData

# ==============================================================================
const Mode := Cell.Mode
# ==============================================================================
@export var mode := Mode.HIDDEN :
	set(new_mode):
		mode = new_mode
		emit_changed()
#@export var object: CellObject = null :
	#set(new_object):
		#if object:
			#object.set_cell(null)
		#
		#object = new_object
		#
		#if new_object:
			#assert(new_object.get_cell() == null, "A CellObject cannot be assigned to multiple cells at once.")
			#new_object.set_cell(self)
			#if not new_object.reloaded:
				#new_object.notify_cell_entered()
			#if not new_object.initialized:
				#new_object.notify_spawned()
			#new_object.reloaded = false
		#
		#emit_changed()
@export var value := 0 :
	set(new_value):
		value = new_value
		emit_changed()
#@export var aura: Aura = null :
	#set(new_aura):
		#var old := aura
		#aura = new_aura
		#if old:
			#old.notify_removed(self)
			#Effects.aura_remove(self, old)
		#emit_changed()
# ==============================================================================
var direction_arrow := Vector2i.ZERO
# ==============================================================================
signal shatter_requested(texture: Texture2D)
signal show_direction_arrow_requested(direction: Vector2i)
signal hide_direction_arrow_requested()
signal text_particle_requested(text: String, color_preset: TextParticles.ColorPreset)
signal scale_object_requested(scale: float)
signal move_object_requested(source: CellData)

signal interacted()
signal second_interacted()

signal changed()
# ==============================================================================

func emit_changed() -> void:
	changed.emit()


#region internals

func _init() -> void:
	child_order_changed.connect(emit_changed)


@warning_ignore("shadowed_variable")
static func _import_packed_v(args: Array) -> CellData:
	var cell := CellData.new()
	assert(args[0] is int, "The first argument of a CellData must be of type \"int\".")
	cell.value = args.pop_front()
	
	var cell_mode := Mode.VISIBLE
	var cell_object: CellObject = null
	var cell_aura: Aura = null
	var stage: StageInstance = null
	for arg in args:
		if arg is int:
			cell_mode = arg
		elif arg is CellObject:
			cell_object = arg
		elif arg is Aura:
			cell_aura = arg
		elif arg is StageInstance:
			stage = arg
	
	cell.mode = cell_mode
	cell.set_object(cell_object)
	cell.set_aura(cell_aura)
	
	var processing_owner := Eternity.get_processing_owner()
	if processing_owner is StageInstance:
		if stage != null and stage != processing_owner:
			Debug.log_warning("A CellData object was created under a StageInstance, but a different StageInstance was provided in the constructor. Ignoring the argument...")
		
		stage = processing_owner
	
	return cell


func _export_packed() -> Array:
	var args := [value]
	if mode != Mode.VISIBLE:
		args.append(mode)
	if is_occupied():
		args.append(get_object())
	if has_aura():
		args.append(get_aura())
	return args


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	emit_changed()

#endregion

#region operations

## Opens this [CellData], showing its contents. Returns [code]true[/code] if the [CellData]
## could be opened, and [code]false[/code] otherwise.
## [br][br]Calls [method Effects.cell_open] immediately after opening the [CellData].
func open(force: bool = false, allow_loot: bool = true) -> bool:
	if is_visible():
		return false
	if not force and is_flagged():
		return false
	
	if not get_stage_instance().is_generated():
		get_stage_instance().generate(self)
	
	
	if value != 0:
		var r := _open(force, allow_loot)
		get_stage_instance().check_completed()
		return r
	
	_open(force, allow_loot)
	
	var to_explore: Array[CellData] = [self]
	var visited: Array[CellData] = []
	while not to_explore.is_empty():
		var current_cell := to_explore.pop_back() as CellData
		
		visited.append(current_cell)
		current_cell._open(force)
		
		if current_cell.value != 0 or current_cell.has_monster():
			continue
		
		for c in current_cell.get_nearby_cells():
			if c in visited or c in to_explore or c.is_revealed() or c.is_flagged():
				continue
			to_explore.append(c)
	
	get_stage_instance().check_completed()
	
	return true


func _open(force: bool = false, allow_loot: bool = true) -> bool:
	if mode == Mode.VISIBLE:
		return false
	if not force and mode == Mode.FLAGGED:
		return false
	
	mode = Mode.VISIBLE
	
	Quest.get_current().get_inventory().mana_gain(value, self)
	
	if allow_loot and not is_occupied() and value == 0:
		spawn_base(get_stage_instance().generate_cell_content(Quest.get_current().get_attributes().rare_loot_modifier))
	
	if is_occupied():
		get_object().notify_revealed(not force)
	
	EffectManager.propagate(get_stage_instance().get_effects().cell_open, [self])
	
	return true


func shatter(texture: Texture2D) -> void:
	shatter_requested.emit(texture)


func reset_value() -> int:
	value = get_real_value()
	return value


## Checks this [CellData], visually pressing it down, if this [CellData] is hidden and not flagged.
func check() -> void:
	if mode == Cell.Mode.HIDDEN:
		mode = Cell.Mode.CHECKING


## Unchecks this [CellData], resetting it to [constant Cell.HIDDEN].
func uncheck() -> void:
	if mode == Cell.Mode.CHECKING:
		mode = Cell.Mode.HIDDEN


## Flags this [CellData]. This prevents it from being opened.
func flag() -> void:
	if mode != Cell.Mode.FLAGGED and not is_revealed():
		mode = Cell.Mode.FLAGGED


## Unflags this [CellData], resetting it to [constant Cell.HIDDEN].
func unflag() -> void:
	if mode == Cell.Mode.FLAGGED:
		mode = Cell.Mode.HIDDEN


func clear_object() -> void:
	get_object().queue_free()


@warning_ignore("shadowed_variable")
func set_object(object: CellObject) -> void:
	if is_occupied():
		clear_object()
	if object:
		add_child(object)


func get_object() -> CellObject:
	for child in get_children():
		if child is CellObject:
			return child
	return null


func move_object_to(cell: CellData) -> void:
	if cell.is_occupied():
		return
	
	var object := get_object()
	remove_child(object)
	cell.set_object(object)
	cell.move_object_requested.emit(self)


func has_monster() -> bool:
	for child in get_children():
		if child is Monster:
			return true
	return false


func set_aura(aura: Aura) -> void:
	if has_aura():
		clear_aura()
	if aura:
		add_child(aura)


func get_aura() -> Aura:
	for child in get_children():
		if child is Aura:
			return child
	return null


func has_aura() -> bool:
	return get_aura() != null and not get_aura().is_queued_for_deletion()


@warning_ignore("shadowed_variable")
func apply_aura(aura: Variant) -> Aura:
	aura = aura.new() if aura is Script else aura
	set_aura(aura)
	if is_occupied():
		get_object().notify_aura_applied()
	EffectManager.propagate(get_stage_instance().get_effects().cell_aura_applied, [aura])
	return aura


func clear_aura() -> void:
	if has_aura():
		get_aura().queue_free()
		EffectManager.propagate(get_stage_instance().get_effects().cell_aura_removed, [get_aura()])


func spawn(base: Script, visible_only: bool = true) -> CellObject:
	return spawn_base(CellObjectBase.new(base), visible_only)


func spawn_base(base: CellObjectBase, visible_only: bool = true) -> CellObject:
	if not base:
		return null
	
	if not is_occupied() and (not visible_only or is_visible()):
		var instance := base.create(get_stage())
		set_object(instance)
		return instance
	
	var visited: Array[CellData] = []
	var queue: Array[CellData] = [self]
	var next_queue: Array[CellData] = []
	
	while queue.size() > 0:
		var unoccupied: Array[CellData] = []
		
		for cell in queue:
			if cell in visited:
				continue
			visited.append(cell)
			
			if not cell.is_occupied() and (not visible_only or cell.is_visible()):
				unoccupied.append(cell)
			
			for neighbor in cell.get_nearby_cells():
				if neighbor not in visited:
					next_queue.append(neighbor)
		
		if not unoccupied.is_empty():
			var cell: CellData = unoccupied.pick_random()
			var instance := base.create(get_stage())
			cell.set_object(instance)
			return instance
		
		queue = next_queue
		next_queue = []
	
	return null


func show_direction_arrow(direcion: Vector2i) -> void:
	direction_arrow = direcion
	show_direction_arrow_requested.emit(direcion)


func hide_direction_arrow() -> void:
	direction_arrow = Vector2i.ZERO
	hide_direction_arrow_requested.emit()


func add_text_particle(text: String, color_preset: TextParticles.ColorPreset = TextParticles.ColorPreset.COINS) -> void:
	text_particle_requested.emit(text, color_preset)


func send_projectile(projectile: Script, direction: Vector2i = Vector2i.ZERO) -> Projectile:
	var instance: Projectile = projectile.new(get_position(), direction)
	instance.sprite = get_stage_instance().get_scene().register_projectile(instance)
	return instance


func scale_object(scale: float) -> void:
	scale_object_requested.emit(scale)


func get_actions() -> Array[Callable]:
	var actions: Array[Callable] = []
	var action_manager := get_stage_instance().get_quest().get_action_manager()
	
	if is_hidden():
		if not is_flagged():
			actions.append(func() -> void:
				check()
			)
		
		actions.append_array(action_manager.get_actions(self))
		
		if actions.is_empty():
			actions.append(func() -> void: pass)
		
		actions.insert(1, func() -> void:
			if is_flagged():
				unflag()
			else:
				flag()
		)
		
		return actions
	
	if is_occupied():
		actions.append_array(get_object().get_actions())
		if actions.is_empty():
			actions.append(func() -> void: pass)
		
		actions.append_array(action_manager.get_actions(self))
		
		return actions
	
	actions.append(func() -> void: # left click (chord)
		for cell in get_nearby_cells():
			if cell.is_hidden() and not cell.is_flagged():
				cell.check()
	)
	actions.append_array(action_manager.get_actions(self))
	actions.append(func() -> void: # right-click (flag-chord)
		var monsters := 0
		for cell in get_nearby_cells():
			if cell.is_hidden() or (cell.has_monster() and cell.is_visible()):
				monsters += 1
		
		if value < monsters:
			return
		
		for cell in get_nearby_cells():
			if cell.is_hidden():
				cell.flag()
	)
	
	return actions


func get_release_actions() -> Array[Callable]:
	var action_manager := get_stage_instance().get_quest().get_action_manager()
	var actions: Array[Callable] = []
	
	if is_hidden():
		if not is_flagged():
			actions.append(func() -> void:
				if get_stage_instance().get_board().get_hovered_cell() != self:
					uncheck()
				else:
					open()
					
					EffectManager.propagate(get_stage_instance().get_effects().turn)
			)
		
		actions.append_array(action_manager.get_release_actions(self))
		
		return actions
	
	if is_occupied():
		if get_object().can_interact():
			actions.append(func() -> void: pass)
		
		actions.append_array(action_manager.get_release_actions(self))
		
		if get_object().can_second_interact():
			if actions.is_empty():
				actions.append(func() -> void: pass)
			actions.insert(1, func() -> void: pass)
		
		return actions
	
	actions.append(func() -> void: # left click (chord)
		var monsters := 0
		var checked_cells: Array[CellData] = []
		for cell in get_nearby_cells():
			if cell.is_flagged() or (cell.has_monster() and cell.is_visible()):
				monsters += 1
			elif cell.get_mode() == Mode.CHECKING:
				checked_cells.append(cell)
		
		var is_still_hovered := get_stage_instance().get_board().get_hovered_cell() == self
		
		if not is_still_hovered or value > monsters:
			for cell in checked_cells:
				cell.uncheck()
		else:
			for cell in checked_cells:
				cell.open()
			
			if not checked_cells.is_empty():
				EffectManager.propagate(get_stage_instance().get_effects().turn)
	)
	actions.append_array(action_manager.get_release_actions(self))
	
	return actions

#endregion

#region getters

func get_screen_position(centered: bool = true) -> Vector2:
	var board := get_stage_instance().get_board()
	return board.get_viewport_transform() * board.get_global_at_cell_position(get_position(), centered)


func is_revealed() -> bool:
	return mode == Mode.VISIBLE


func is_visible() -> bool:
	return is_revealed()


func is_hidden() -> bool:
	return not is_revealed()


func is_flagged() -> bool:
	return mode == Mode.FLAGGED


func is_occupied() -> bool:
	return get_object() != null


func is_empty() -> bool:
	return get_object() == null


## Returns whether this [CellData] is solved. This can mean 2 things:
## [br][br]If this cell is hidden, this returns true if this cell has a monster and
## is flagged, or if this cell does not have a monster and is not flagged.
## [br][br]If this cell is visible, this returns true if this cell's value is at most
## the number of nearby flags + monsters.
func is_solved() -> bool:
	if is_hidden():
		return is_flagged() == has_monster()
	
	var count := 0
	for cell in get_nearby_cells():
		if cell.is_flagged() or (cell.is_revealed() and cell.has_monster()):
			count += 1
	
	return count >= value


## Returns whether this [Cell] has at most as many nearby hidden [Cell]s and visible
## monsters as this cell's value.
func is_flag_solved() -> bool:
	var count := 0
	for cell in get_nearby_cells():
		if cell.is_hidden() or cell.has_monster():
			count += 1
	
	return count == value


func get_stage_instance() -> StageInstance:
	var base := get_parent()
	while base != null and base is not StageInstance:
		base = base.get_parent()
	return base


func get_stage() -> Stage:
	var instance := get_stage_instance()
	return instance.get_stage() if instance else null


func get_position() -> Vector2i:
	var idx := get_index()
	assert(idx >= 0, "The provided StageInstance does not contain this cell.")
	return Vector2i(idx % get_stage_instance().get_stage().size.x, idx / get_stage_instance().get_stage().size.x)


func get_nearby_cells() -> Array[CellData]:
	const DIRECTIONS: Array[Vector2i] = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1, 0),                   Vector2i(1, 0),
		Vector2i(-1, 1),  Vector2i(0, 1),  Vector2i(1, 1)
	]
	
	var position := get_position()
	
	var cells: Array[CellData] = []
	for dir in DIRECTIONS:
		var cell := get_stage_instance().get_cell(position + dir)
		if cell:
			cells.append(cell)
	
	return cells


func get_real_value() -> int:
	var real_value := 0
	for cell in get_nearby_cells():
		if cell.is_occupied():
			real_value += cell.get_object().get_value_contribution()
	return real_value


func get_group() -> Array[CellData]:
	var group: Array[CellData] = []
	var to_explore: Array[CellData] = [self]
	var visited: Array[CellData] = []
	
	while not to_explore.is_empty():
		var current_cell: CellData = to_explore.pop_front()
		if current_cell in visited:
			continue
		
		visited.append(current_cell)
		group.append(current_cell)
		
		for cell in current_cell.get_nearby_cells():
			if not cell in visited and cell.value == value:
				to_explore.append(cell)
	
	return group


func get_mode() -> Mode:
	return mode

#endregion

#region notifiers

func notify_interacted() -> void:
	interacted.emit()
	if is_occupied() and is_visible():
		get_object().notify_interacted()
	if has_aura():
		get_aura().notify_interacted(self)
	
	EffectManager.propagate(get_stage_instance().get_effects().cell_interacted, [self])


func notify_second_interacted() -> void:
	second_interacted.emit()
	if is_occupied() and is_visible():
		get_object().notify_second_interacted()
	if has_aura():
		get_aura().notify_second_interacted(self)
	
	EffectManager.propagate(get_stage_instance().get_effects().cell_second_interacted, [self])

#endregion
