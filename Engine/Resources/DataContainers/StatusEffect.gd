@tool
extends Node
class_name StatusEffect

# ==============================================================================
const IMAGE_SIZE := Vector2i(8, 8)
# ==============================================================================
enum Type {
	TURNS,
	CELLS_OPENED,
	SECONDS,
}
# ==============================================================================
@export var source: Collectible = null :
	set(value):
		source = value
		_texture = null
		emit_changed()
		
		# TODO: this method of preserving the source may somtimes cause problems
		# we need a different system where it never gets queue_free()-ed
		# though starting at 4.5 (hopefully, otherwise 4.6), this should work fine.
		source.predelete.connect(func() -> void:
			if is_ancestor_of(source) or self.is_queued_for_deletion():
				return
			
			source.cancel_free()
			
			if source.get_parent() != null:
				# the source was removed together with its parent
				source.get_parent().remove_child(source)
			
			add_child(source)
			await source.tree_exited
			add_child(source)
		)
		#source.tree_exiting.connect(func() -> void:
			#if is_ancestor_of(source):
				#await source.tree_exited
				#add_child(source)
		#)

#@export var quest: Quest = null :
	#set(value):
		#if quest:
			#_disconnect_signals()
		#
		#quest = value
		#
		#if _loaded and value and value == Quest.get_current():
			#_connect_signals()
		#
		#emit_changed()

@export var _origin := 0 :
	set(value):
		_origin = value
		emit_changed()
@export var _duration := 0 : set = _set_duration, get = get_duration

@export var _type := Type.TURNS : set = _set_type, get = get_type
@export var _reset_on_mistake := false :
	set(value):
		_reset_on_mistake = value
		emit_changed()
@export var _loops := 1 :
	set(value):
		_loops = value
		emit_changed()
# ==============================================================================
var _texture: Texture2D = null : get = get_texture

var _loaded := false
var _finished := false : get = is_finished
# ==============================================================================
signal loop_finished()
signal finished()

signal changed()
# ==============================================================================

func emit_changed() -> void:
	changed.emit()


func start() -> void:
	_start()


func kill() -> void:
	_disconnect_signals()
	
	_kill()
	_end()

#region internals

func _connect_signals() -> void:
	get_quest().get_stage_effects().mistake_made.connect(notify_mistake)
	
	match _type:
		Type.TURNS:
			get_quest().get_stage_effects().turn.connect(notify_turn)
		Type.CELLS_OPENED:
			get_quest().get_stage_effects().cell_open.connect(notify_cell_opened)
		Type.SECONDS:
			get_quest().get_effects().status_effect_second_passed.connect(notify_second_passed)


func _disconnect_signals() -> void:
	get_quest().get_stage_effects().mistake_made.disconnect(notify_mistake)
	
	match _type:
		Type.TURNS:
			get_quest().get_stage_effects().turn.disconnect(notify_turn)
		Type.CELLS_OPENED:
			get_quest().get_stage_effects().cell_open.disconnect(notify_cell_opened)
		Type.SECONDS:
			get_quest().get_effects().status_effect_second_passed.disconnect(notify_second_passed)

#endregion

#region virtuals

## Virtual method. Called when this status effect is started.
func _start() -> void:
	pass


## Notifies this [StatusEffect] that is has been loaded.
func notify_loaded() -> void:
	if not _loaded:
		_loaded = true
		
		_connect_signals()
		_load()


## Virtual method. Called whenever this status effect is loaded. This may be
## when it is created, or when it is loaded from disk.
func _load() -> void:
	pass


## Virtual method. Called when this status effect ends (either by finishing or by
## being killed).
func _end() -> void:
	pass


## Virtual method. Called when this status effect is killed.
func _kill() -> void:
	pass


## Virtual method. Called when this status effect  is finished.
func _finish() -> void:
	pass


## Notifies this [StatusEffect] that the player has passed a turn.
func notify_turn() -> void:
	if _type == Type.TURNS:
		_duration -= 1
		_turn()


## Virtual method. If this is a [constant TURN] status, this is called every time the
## player passes a turn.
func _turn() -> void:
	pass


## Notifies this [StatusEffect] that the player has opened a cell.
func notify_cell_opened(cell: CellData = null) -> void:
	if _type == Type.CELLS_OPENED:
		_duration -= 1
		_cell_open(cell)


## Virtual method. If this is a [constant CELLS_OPENED] status, this is called every time the
## player opens a cell.
@warning_ignore("unused_parameter")
func _cell_open(cell: CellData) -> void:
	pass


## Notifies this [StatusEffect] that a second has passed.
func notify_second_passed() -> void:
	if _type == Type.SECONDS:
		_duration -= 1
		_second_passed()


## Virtual method. If this is a [constant SECONDS] status, this is called once every
## second while the current [StageTimer] is running.
func _second_passed() -> void:
	pass


## Notifies this [StatusEffect] that the player has made a mistake.
func notify_mistake(cell: CellData = null) -> void:
	if _reset_on_mistake:
		_duration = _origin
	_mistake(cell)


## Virtual method. Called every time the player makes a mistake.
@warning_ignore("unused_parameter")
func _mistake(cell: CellData) -> void:
	pass

#endregion

#region getters

func get_quest() -> Quest:
	var base := get_parent()
	while base != null and base is not Quest:
		base = base.get_parent()
	return base


func get_texture() -> Texture2D:
	if _texture:
		return _texture
	
	var image := source.get_texture().get_image().duplicate() as Image
	image.resize(IMAGE_SIZE.x, IMAGE_SIZE.y, Image.INTERPOLATE_NEAREST)
	_texture = ImageTexture.create_from_image(image)
	
	return _texture


func is_finished() -> bool:
	return _finished


func _set_duration(value: int) -> void:
	_duration = value
	
	while _duration <= 0 and _origin > 0:
		if _loops == 1:
			_finished = true
			
			_finish()
			_end()
			
			_disconnect_signals()
			
			finished.emit()
			break
		
		_duration += _origin
		if _loops > 1:
			_loops -= 1
		
		loop_finished.emit()
	
	emit_changed()


func get_duration() -> int:
	return _duration


func _set_type(value: Type) -> void:
	_type = value
	emit_changed()


func get_type() -> Type:
	return _type

#endregion

static func create(status_script: Script = null) -> Initializer:
	return Initializer.new(status_script if status_script else StatusEffect)


class Initializer:
	var _quest: Quest = null
	var _status_script: Script
	
	var _duration := 0
	var _origin := 0
	var _type := Type.TURNS
	var _reset_on_mistake := false
	var _source: Collectible = null
	var _loops := 1
	
	var _joined := false
	
	func _init(status_script: Script = StatusEffect) -> void:
		_status_script = status_script
	
	func set_quest(quest: Quest) -> Initializer:
		_quest = quest
		return self
	
	func set_duration(duration: int, origin: bool = true) -> Initializer:
		_duration = duration
		if origin:
			return set_origin()
		return self
	
	func set_origin(origin: int = _duration) -> Initializer:
		_origin = origin
		return self
	
	func set_type(type: Type) -> Initializer:
		_type = type
		return self
	
	func set_turns(turns: int = _duration, origin: bool = true) -> Initializer:
		return set_duration(turns, origin).set_type(Type.TURNS)
	
	func set_cells(cells: int = _duration, origin: bool = true) -> Initializer:
		return set_duration(cells, origin).set_type(Type.CELLS_OPENED)
	
	func set_seconds(seconds: int = _duration, origin: bool = true) -> Initializer:
		return set_duration(seconds, origin).set_type(Type.SECONDS)
	
	func set_reset_on_mistake(reset_on_mistake: bool = true) -> Initializer:
		_reset_on_mistake = reset_on_mistake
		return self
	
	func set_source(source: Collectible) -> Initializer:
		_source = source
		return self
	
	func set_loops(loops: int = 0) -> Initializer:
		_loops = loops
		return self
	
	func set_joined(joined: bool = true) -> Initializer:
		_joined = joined
		return self
	
	func start() -> StatusEffect:
		var manager := _quest.get_status_manager()
		
		if _joined and _source:
			for status in manager.get_status_effects():
				if status.get_script() != _status_script:
					continue
				if status.get_type() != _type:
					Debug.log_error("Cannot join status effects '%s': type mismatch." % UserClassDB.script_get_identifier(_source.get_script()))
					break # we'll create a new status effect instead since I don't want to return null
				
				status._duration += _duration
				return status
		
		var base := _status_script
		while base != StatusEffect:
			base = base.get_base_script()
			if base == null:
				Debug.log_error("Cannot create a status effect for '%s': The provided status_script must extend StatusEffect." % UserClassDB.script_get_identifier(_status_script))
				_status_script = StatusEffect
				break
		
		var status := _status_script.new() as StatusEffect
		status._duration = _duration
		status._origin = _origin
		status._type = _type
		status._reset_on_mistake = _reset_on_mistake
		status.source = _source
		
		manager.add_status_effect(status)
		
		status.start()
		
		return status
