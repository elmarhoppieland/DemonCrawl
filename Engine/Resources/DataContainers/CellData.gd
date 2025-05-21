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
@export var object: CellObject :
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
		aura = new_aura
		emit_changed()
# ==============================================================================
var direction_arrow := Vector2i.ZERO
# ==============================================================================
signal shatter_requested(texture: Texture2D)
signal show_direction_arrow_requested(direction: Vector2i)
signal hide_direction_arrow_requested()
signal text_particle_requested(text: String, color_preset: TextParticles.ColorPreset)
signal scale_object_requested(scale: float)
signal move_object_requested(source: CellData)
# ==============================================================================

#region internals

@warning_ignore("shadowed_variable")
static func _import_packed(value: int, arg0: Variant = null, arg1: Variant = null, arg2: Variant = null) -> CellData:
	var cell := CellData.new()
	cell.value = value
	
	var mode := Mode.VISIBLE
	var object: CellObject = null
	var aura: Aura = null
	for arg in [arg0, arg1, arg2]:
		if arg == null:
			continue
		if arg is int:
			mode = arg
		elif arg is CellObject:
			object = arg
		elif arg is Aura:
			aura = arg
	
	cell.mode = mode
	cell.object = object
	cell.aura = aura
	
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
func open(force: bool = false, allow_loot: bool = true, stage: Stage = Stage.get_current()) -> bool:
	if get_mode() == Mode.VISIBLE:
		return false
	if not force and get_mode() == Mode.FLAGGED:
		return false
	
	if not stage.get_instance().is_generated():
		stage.get_instance().generate(self)
	
	if value != 0:
		return _open(force, allow_loot, stage)
	
	var to_explore: Array[CellData] = [self]
	var visited: Array[CellData] = []
	
	while not to_explore.is_empty():
		var current_cell := to_explore.pop_back() as CellData
		
		visited.append(current_cell)
		current_cell._open(force, allow_loot, stage)
		
		if current_cell.value != 0 or current_cell.object is Monster:
			continue
		
		for c in current_cell.get_nearby_cells():
			if c in visited or c in to_explore or c.is_revealed() or c.is_flagged():
				continue
			to_explore.append(c)
	
	return true


func _open(force: bool = false, allow_loot: bool = true, stage: Stage = Stage.get_current()) -> bool:
	if mode == Mode.VISIBLE:
		return false
	if not force and mode == Mode.FLAGGED:
		return false
	
	mode = Mode.VISIBLE
	
	Quest.get_current().get_inventory().mana_gain(value, self)
	
	if allow_loot and not is_occupied() and value == 0:
		spawn_base(stage.get_instance().generate_cell_content(Quest.get_current().get_attributes().rare_loot_modifier))
		#spawn(preload("res://Assets/loot_tables/Loot.tres").generate(1 / (1 - get_stage().get_density())))
	
	if is_occupied():
		object.notify_revealed(not force)
	
	Effects.cell_open(self)
	
	return true


func shatter(texture: Texture2D) -> void:
	shatter_requested.emit(texture)


func reset_value(instance: StageInstance = Stage.get_current().get_instance()) -> int:
	value = get_real_value(instance)
	return value


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
func apply_aura(aura: Script) -> Aura:
	self.aura = Aura.create(aura)
	if is_occupied():
		object.notify_aura_applied()
	return self.aura


func spawn(base: Script, visible_only: bool = true, stage: Stage = Stage.get_current()) -> CellObject:
	return spawn_base(CellObjectBase.new(base), visible_only, stage)


func spawn_base(base: CellObjectBase, visible_only: bool = true, stage: Stage = Stage.get_current()) -> CellObject:
	if not base:
		return null
	
	if not is_occupied() and (not visible_only or is_visible()):
		var instance := base.create(stage)
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
			var instance := base.create(stage)
			cell.object = instance
			return instance
		
		queue = next_queue
		next_queue = []
	
	return null


func create_tween(instance: StageInstance = Stage.get_current().get_instance()) -> Tween:
	var board := instance.get_stage().get_board()
	assert(board != null, "Cannot create a Tween on a Stage that doesn't have a board.")
	
	var position := get_position(instance)
	return board.get_cell(position).create_tween()


func show_direction_arrow(direcion: Vector2i) -> void:
	direction_arrow = direcion
	show_direction_arrow_requested.emit(direcion)


func hide_direction_arrow() -> void:
	direction_arrow = Vector2i.ZERO
	hide_direction_arrow_requested.emit()


func add_text_particle(text: String, color_preset: TextParticles.ColorPreset = TextParticles.ColorPreset.COINS) -> void:
	text_particle_requested.emit(text, color_preset)


func send_projectile(projectile: Script, direction: Vector2i = Vector2i.ZERO, stage_instance: StageInstance = Stage.get_current().get_instance()) -> Projectile:
	var instance: Projectile = projectile.new(get_position(stage_instance), direction)
	instance.sprite = stage_instance.get_scene().register_projectile(instance)
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


func get_position(instance: StageInstance = Stage.get_current().get_instance()) -> Vector2i:
	var idx := instance.cells.find(self)
	assert(idx >= 0, "The provided StageInstance does not contain this cell.")
	return Vector2i(idx % instance.get_stage().size.x, idx / instance.get_stage().size.x)


func get_nearby_cells(instance: StageInstance = Stage.get_current().get_instance()) -> Array[CellData]:
	const DIRECTIONS: Array[Vector2i] = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1, 0),                   Vector2i(1, 0),
		Vector2i(-1, 1),  Vector2i(0, 1),  Vector2i(1, 1)
	]
	
	var position := get_position(instance)
	
	var cells: Array[CellData] = []
	for dir in DIRECTIONS:
		var cell := instance.get_cell(position + dir)
		if cell:
			cells.append(cell)
	
	return cells


func get_real_value(instance: StageInstance = Stage.get_current().get_instance()) -> int:
	var real_value := 0
	for cell in get_nearby_cells(instance):
		if cell.is_occupied():
			real_value += cell.object.get_value_contribution()
	return real_value


func get_group(instance: StageInstance = Stage.get_current().get_instance()) -> Array[CellData]:
	var group: Array[CellData] = []
	var to_explore: Array[CellData] = [self]
	var visited: Array[CellData] = []
	
	while not to_explore.is_empty():
		var current_cell: CellData = to_explore.pop_front()
		if current_cell in visited:
			continue
		
		visited.append(current_cell)
		group.append(current_cell)
		
		for cell in current_cell.get_nearby_cells(instance):
			if not cell in visited and cell.value == value:
				to_explore.append(cell)
	
	return group


func get_mode() -> Mode:
	return mode

#endregion

class ObjectArray:
	var _objects: Array[Object] = []
	
	func _init(objects: Array[Object]) -> void:
		_objects = objects
	
	func propagate(callable: Callable) -> ObjectArray:
		for object in _objects:
			callable.call(object)
		return self
