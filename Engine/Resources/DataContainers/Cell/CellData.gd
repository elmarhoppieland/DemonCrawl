@tool
extends Resource
class_name CellData

# ==============================================================================
const Mode := Cell.Mode
# ==============================================================================
@export var mode := Mode.HIDDEN :
	set(new_mode):
		mode = new_mode
		emit_changed()
@export var object: CellObject = null :
	set(new_object):
		if object:
			object.set_cell(null)
		
		object = new_object
		
		if new_object:
			assert(new_object.get_cell() == null, "A CellObject cannot be assigned to multiple cells at once.")
			new_object.set_cell(self)
			if not new_object.reloaded:
				new_object.notify_cell_entered()
			if not new_object.initialized:
				new_object.notify_spawned()
			new_object.reloaded = false
		
		emit_changed()
@export var value := 0 :
	set(new_value):
		value = new_value
		emit_changed()
@export var aura: Aura = null :
	set(new_aura):
		var old := aura
		aura = new_aura
		if old:
			old.notify_removed(self)
			Effects.aura_remove(self, old)
		emit_changed()
# ==============================================================================
var direction_arrow := Vector2i.ZERO

var _stage_instance_weakref: WeakRef = null
# ==============================================================================
signal shatter_requested(texture: Texture2D)
signal show_direction_arrow_requested(direction: Vector2i)
signal hide_direction_arrow_requested()
signal text_particle_requested(text: String, color_preset: TextParticles.ColorPreset)
signal scale_object_requested(scale: float)
signal move_object_requested(source: CellData)

signal interacted()
signal second_interacted()
# ==============================================================================

#region internals

@warning_ignore("shadowed_variable")
static func _import_packed_v(args: Array) -> CellData:
	var cell := CellData.new()
	assert(args[0] is int, "The first argument of a CellData must be of type \"int\".")
	cell.value = args.pop_front()
	
	var mode := Mode.VISIBLE
	var object: CellObject = null
	var aura: Aura = null
	var stage: StageInstance = null
	for arg in args:
		if arg is int:
			mode = arg
		elif arg is CellObject:
			object = arg
		elif arg is Aura:
			aura = arg
		elif arg is StageInstance:
			stage = arg
	
	cell.mode = mode
	cell.object = object
	cell.aura = aura
	
	var owner := Eternity.get_processing_owner()
	if owner is StageInstance:
		if stage != null and stage != owner:
			Debug.log_warning("A CellData object was created under a StageInstance, but a different StageInstance was provided in the constructor. Ignoring the argument...")
		
		stage = owner
	
	cell.set_stage_instance(stage)
	
	if aura:
		stage.loaded.connect(aura.initialize_on_cell.bind(cell), CONNECT_ONE_SHOT)
	
	return cell


func _export_packed() -> Array:
	var args := [value]
	if mode != Mode.VISIBLE:
		args.append(mode)
	if object != null:
		args.append(object)
	if aura != null:
		args.append(aura)
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
		return _open(force, allow_loot)
	
	_open(force, allow_loot)
	
	var to_explore: Array[CellData] = [self]
	var visited: Array[CellData] = []
	while not to_explore.is_empty():
		var current_cell := to_explore.pop_back() as CellData
		
		visited.append(current_cell)
		current_cell._open(force)
		
		if current_cell.value != 0 or current_cell.object is Monster:
			continue
		
		for c in current_cell.get_nearby_cells():
			if c in visited or c in to_explore or c.is_revealed() or c.is_flagged():
				continue
			to_explore.append(c)
	
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
		object.notify_revealed(not force)
	
	Effects.cell_open(self)
	
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
	object = null


@warning_ignore("shadowed_variable")
func set_object(object: CellObject) -> void:
	self.object = object


func move_object_to(cell: CellData) -> void:
	var obj := object
	set_object(null)
	cell.set_object(obj)
	cell.move_object_requested.emit(self)


@warning_ignore("shadowed_variable")
func apply_aura(aura: Variant) -> Aura:
	self.aura = aura.new() if aura is Script else aura
	self.aura.notify_applied(self)
	if is_occupied():
		object.notify_aura_applied()
	Effects.aura_apply(self)
	return self.aura


func clear_aura() -> void:
	self.aura = null
	if is_occupied():
		object.notify_aura_removed()


func spawn(base: Script, visible_only: bool = true) -> CellObject:
	return spawn_base(CellObjectBase.new(base), visible_only)


func spawn_base(base: CellObjectBase, visible_only: bool = true) -> CellObject:
	if not base:
		return null
	
	if not is_occupied() and (not visible_only or is_visible()):
		var instance := base.create(get_stage())
		object = instance
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
			cell.object = instance
			return instance
		
		queue = next_queue
		next_queue = []
	
	return null


func create_tween() -> Tween:
	var board := get_stage_instance().get_board()
	assert(board != null, "Cannot create a Tween on a Stage that doesn't have a board.")
	
	var position := get_position()
	return board.get_cell(position).create_tween()


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

#endregion

#region getters

func is_revealed() -> bool:
	return mode == Mode.VISIBLE


func is_visible() -> bool:
	return is_revealed()


func is_hidden() -> bool:
	return not is_revealed()


func is_flagged() -> bool:
	return mode == Mode.FLAGGED


func is_occupied() -> bool:
	return object != null


func is_empty() -> bool:
	return object == null


func set_stage_instance(stage_instance: StageInstance) -> void:
	_stage_instance_weakref = weakref(stage_instance) if stage_instance else null


func get_stage_instance() -> StageInstance:
	return _stage_instance_weakref.get_ref() if _stage_instance_weakref else StageInstance.get_current()


func get_stage() -> Stage:
	var instance := get_stage_instance()
	return instance.get_stage() if instance else null


func get_position() -> Vector2i:
	var idx := get_stage_instance().cells.find(self)
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
			real_value += cell.object.get_value_contribution()
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
	if object and is_visible():
		object.notify_interacted()
	if aura:
		aura.notify_interacted(self)
	
	Effects.cell_interact(self)


func notify_second_interacted() -> void:
	second_interacted.emit()
	if object and is_visible():
		object.notify_second_interacted()
	if aura:
		aura.notify_second_interacted(self)
	
	Effects.cell_second_interact(self)

#endregion
