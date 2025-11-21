@tool
extends Node
class_name CellData

# ==============================================================================
enum ModeFlags {
	VISIBLE = 0b0001,
	CHECKING = 0b0010,
	FLAGGED = 0b0100,
	VALUE_VISIBLE = 0b1000,
}
enum Mode {
	INVALID = -1, ## Used as an invalid mode. A cell may never have this mode.
	HIDDEN = 0, ## The cell is hidden, i.e. not yet revealed, but the cell is not flagged.
	GLEANED = ModeFlags.VALUE_VISIBLE, ## The cell is hidden and has been gleaned, but is not flagged.
	GLEANED_FLAGGED = ModeFlags.FLAGGED | ModeFlags.VALUE_VISIBLE, ## The cell is hidden and gleaned and has been flagged.
	VISIBLE_EMPTY = ModeFlags.VISIBLE | ModeFlags.VALUE_VISIBLE, ## The cell is visible and not occupied.
	VISIBLE_OCCUPIED = ModeFlags.VISIBLE, ## The cell is visible and occupied.
	CHECKING = ModeFlags.CHECKING, ## The player is currently checking this cell, i.e. the cell is visually pressed down. It is still considered hidden.
	FLAGGED = ModeFlags.FLAGGED, ## The cell is hidden and flagged.
}
# ==============================================================================
@export var mode: int = Mode.HIDDEN :
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
static func _import_packed(value: int, ...args: Array) -> CellData:
	var cell := CellData.new()
	cell.value = value
	
	var cell_mode := Mode.VISIBLE_EMPTY
	var children: Array[Node] = []
	for arg in args:
		if arg is int:
			cell_mode = arg
		elif arg is Node:
			children.append(arg)
	
	cell.mode = cell_mode
	for child in children:
		cell.add_child(child)
	
	return cell


func _export_packed() -> Array:
	var args := [value, mode]
	args.append_array(get_children())
	return args


func _validate_property(property: Dictionary) -> void:
	if property.name == "mode":
		property.hint = PROPERTY_HINT_FLAGS
		property.hint_string = ",".join(ModeFlags.keys().map(func(key: String) -> String: return key.capitalize()))


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	emit_changed()

#endregion

#region operations

## Opens this [CellData], showing its contents. Returns [code]true[/code] if the [CellData]
## could be opened, and [code]false[/code] otherwise.
func open(allow_loot: bool = true) -> bool:
	if is_visible():
		return false
	if is_flagged():
		return false
	
	if not get_stage_instance().is_generated():
		get_stage_instance().generate(self)
	
	_propagate_open(true, allow_loot)
	
	get_stage_instance().check_completed()
	
	return true


func reveal(allow_loot: bool = true) -> bool:
	if is_visible():
		return false
	
	if not get_stage_instance().is_generated():
		get_stage_instance().generate(self)
	
	_propagate_open(false, allow_loot)
	
	get_stage_instance().check_completed()
	
	return true


func _open(active: bool = true, allow_loot: bool = true) -> bool:
	mode &= ~ModeFlags.FLAGGED & ~ModeFlags.CHECKING
	mode |= ModeFlags.VISIBLE
	
	Quest.get_current().get_inventory().mana_gain(value, self)
	
	if allow_loot and not is_occupied() and value == 0:
		spawn_base(get_stage_instance().generate_cell_content(Quest.get_current().get_attributes().rare_loot_modifier))
	
	if is_occupied():
		get_object().notify_revealed(active)
	
	EffectManager.propagate(get_stage_instance().get_cell_effects().opened, self)
	
	return true


func _propagate_open(active: bool = true, allow_loot: bool = true) -> void:
	var to_explore: Array[CellData] = [self]
	var visited: Array[CellData] = []
	while not to_explore.is_empty():
		var current_cell := to_explore.pop_back() as CellData
		
		visited.append(current_cell)
		current_cell._open(active, allow_loot)
		
		if current_cell.value != 0 or current_cell.has_monster():
			continue
		
		for c in current_cell.get_nearby_cells():
			if c in visited or c in to_explore or c.is_visible() or c.is_flagged():
				continue
			to_explore.append(c)
	
	EffectManager.propagate(get_stage_instance().get_cell_effects().open_propagation_finished, visited)


func shatter(texture: Texture2D) -> void:
	shatter_requested.emit(texture)


func reset_value() -> int:
	value = get_real_value()
	return value


## Checks this [CellData], visually pressing it down, if this [CellData] is hidden and not flagged.
func check() -> void:
	if is_hidden() and not is_flagged():
		mode |= ModeFlags.CHECKING


## Unchecks this [CellData], resetting it to [constant Cell.HIDDEN].
func uncheck() -> void:
	mode &= ~ModeFlags.CHECKING


## Flags this [CellData]. This prevents it from being opened.
func flag() -> void:
	if is_hidden():
		mode |= ModeFlags.FLAGGED
		mode &= ~ModeFlags.CHECKING


## Unflags this [CellData], resetting it to [constant Cell.HIDDEN].
func unflag() -> void:
	mode &= ~ModeFlags.FLAGGED


## Makes this [CellData]'s value visible.
func glean() -> void:
	mode |= ModeFlags.VALUE_VISIBLE


## Makes this [CellData]'s value invisible, if it was made visible using [method glean].
## [br][br][b]Note:[/b] If this [CellData] is visible and empty, its value is always visible.
func unglean() -> void:
	mode &= ~ModeFlags.VALUE_VISIBLE


func clear_object() -> void:
	get_object().queue_free()


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


func apply_aura(aura: Variant) -> Aura:
	aura = aura.new() if aura is Script else aura
	set_aura(aura)
	if is_occupied():
		get_object().notify_aura_applied()
	EffectManager.propagate(get_stage_instance().get_cell_effects().aura_applied, aura)
	return aura


func clear_aura() -> void:
	if has_aura():
		get_aura().queue_free()
		EffectManager.propagate(get_stage_instance().get_cell_effects().aura_removed, get_aura())


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
		
		actions.append(func() -> void:
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
	return is_visible()


func is_visible() -> bool:
	return mode & ModeFlags.VISIBLE


func is_hidden() -> bool:
	return not is_visible()


func is_flagged() -> bool:
	return mode & ModeFlags.FLAGGED


func is_checking() -> bool:
	return mode & ModeFlags.CHECKING


func is_value_visible() -> bool:
	if is_visible() and value == 0:
		return false
	return mode & ModeFlags.VALUE_VISIBLE or (is_visible() and is_empty())


func is_occupied() -> bool:
	return not is_empty()


func is_empty() -> bool:
	return get_object() == null or get_object().is_queued_for_deletion()


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
		if cell.is_flagged() or (cell.is_visible() and cell.has_monster()):
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


func get_mode() -> int:
	return mode

#endregion

#region notifiers

func notify_interacted() -> void:
	if is_occupied() and is_visible():
		get_object().notify_interacted()
	if has_aura():
		get_aura().notify_interacted()
	
	interacted.emit()
	EffectManager.propagate(get_stage_instance().get_cell_effects().interacted, self)


func notify_second_interacted() -> void:
	second_interacted.emit()
	if is_occupied() and is_visible():
		get_object().notify_second_interacted()
	if has_aura():
		get_aura().notify_second_interacted(self)
	
	EffectManager.propagate(get_stage_instance().get_cell_effects().second_interacted, self)

#endregion

@warning_ignore_start("unused_signal")

class CellEffects extends EventBus:
	signal opened(cell: CellData)
	signal open_propagation_finished(cells: Array[CellData])
	
	signal aura_applied(aura: Aura)
	signal aura_removed(aura: Aura)
	
	signal interacted(cell: CellData)
	signal second_interacted(cell: CellData)
	
	signal mistake_made(cell: CellData)

@warning_ignore_restore("unused_signal")
