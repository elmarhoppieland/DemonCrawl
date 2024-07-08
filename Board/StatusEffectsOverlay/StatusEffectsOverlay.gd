extends CanvasLayer
class_name StatusEffectsOverlay

# ==============================================================================
static var _instance: StatusEffectsOverlay

static var _status_effects := {}
static var status_effect_data: Dictionary = Eternal.create({}) :
	set(value):
		status_effect_data = value
		
		_status_effects.clear()
		
		for uid in status_effect_data:
			var data: StatusEffectData = status_effect_data[uid]
			StatusEffect.create(uid)\
				.set_type(data.type)\
				.set_duration(data.duration, false)\
				.set_origin(data.origin)\
				.set_attribute(data.attribute)\
				.set_source(Item.from_path(data.source))\
			.start()
	get:
		status_effect_data.clear()
		
		for uid in _status_effects:
			var data := StatusEffectData.new()
			var status := get_status_effect(uid)
			data.attribute = status.attribute
			data.origin = status.origin
			data.duration = status.duration
			data.type = status.type
			data.item_path = status.source.get_script().resource_path.get_basename()
			
			status_effect_data[uid] = data
		
		return status_effect_data
# ==============================================================================
@onready var _status_effect_container: VBoxContainer = %StatusEffectContainer
# ==============================================================================

func _enter_tree() -> void:
	_instance = self


func _exit_tree() -> void:
	if _instance == self:
		_instance = null


func _ready() -> void:
	var effects: Array[StatusEffect] = []
	effects.assign(_status_effects.values())
	
	effects.sort_custom(func(a: StatusEffect, b: StatusEffect): return a.sort_order < b.sort_order)
	
	for effect in effects:
		_status_effect_container.add_child(effect)


static func add_status_effect(status_effect: StatusEffect, uid: String = "") -> void:
	if uid.is_empty():
		uid = create_id()
	if has_id(uid):
		return
	
	status_effect.sort_order = get_status_count()
	_status_effects[uid] = status_effect
	if _instance:
		_instance._status_effect_container.add_child(status_effect)


static func get_status_effect(uid: String) -> StatusEffect:
	var status = _status_effects.get(uid)
	if is_instance_valid(status):
		return status
	return null


static func remove_status_effect(status_effect: StatusEffect, keep_instance: bool = false) -> void:
	if _instance:
		_instance._status_effect_container.remove_child(status_effect)
	
	if not keep_instance:
		status_effect.queue_free()


static func get_status_count() -> int:
	return _status_effects.values().filter(func(status: StatusEffect): return status != null).size()


static func create_id() -> String:
	const CHARS := "abcdefghijklmnopqrstuvwxyz0123456789"
	const UID_LENGTH := 8
	
	var uid := "".join(range(UID_LENGTH).map(func(_i: int): return CHARS[randi() % CHARS.length()]))
	
	if uid in _status_effects:
		return create_id() # try again
	
	return uid


static func add_id(uid: String) -> void:
	if uid in _status_effects:
		return
	
	_status_effects[uid] = null


static func remove_id(uid: String) -> StatusEffect:
	if has_id(uid):
		var effect := get_status_effect(uid)
		
		if effect and _instance:
			_instance._status_effect_container.remove_child(effect)
		_status_effects.erase(uid)
		
		return effect
	
	return null


static func get_id_count() -> int:
	return _status_effects.size()


static func has_id(uid: String) -> bool:
	return uid in _status_effects


class StatusEffectData:
	var attribute: Object
	var origin := -1
	var duration := -1
	var type := StatusEffect.Type.TURNS
	var item_path := ""
