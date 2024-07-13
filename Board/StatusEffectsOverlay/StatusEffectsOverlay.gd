extends CanvasLayer
class_name StatusEffectsOverlay

# ==============================================================================
static var _instance: StatusEffectsOverlay

static var _status_effects := {}
static var status_effect_data: Dictionary = Eternal.create({}) :
	set(value):
		status_effect_data = value
		
		for status in get_status_effects():
			status.queue_free()
		
		_status_effects.clear()
		
		for uid: String in value:
			_status_effects[uid] = null if value[uid].is_empty() else StatusEffect.from_dict(value[uid])
			# we don't need to add it to the SceneTree because we load on the main menu
			# it will be added in _ready()
	get:
		status_effect_data.clear()
		
		for uid in _status_effects:
			var status := get_status_effect(uid)
			status_effect_data[uid] = status.to_dict() if status else {}
		
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
	var effects := StatusEffectsOverlay.get_status_effects()
	effects.sort_custom(func(a: StatusEffect, b: StatusEffect): return a.sort_order < b.sort_order)
	
	for status in effects:
		_status_effect_container.add_child(status)
	
	# we don't want the status effects to be freed when we change scenes so we quickly remove them from the scene tree
	EffectManager.connect_effect(func stage_leave() -> void:
		for status in StatusEffectsOverlay.get_status_effects():
			_status_effect_container.remove_child(status)
	, false, false, &"stage_leave")


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


static func get_status_effects() -> Array[StatusEffect]:
	return Array(_status_effects.values().filter(func(s: StatusEffect): return is_instance_valid(s)), TYPE_OBJECT, (StatusEffect as Script).get_instance_base_type(), StatusEffect)


static func remove_status_effect(status_effect: StatusEffect, keep_instance: bool = false, keep_uid: bool = false) -> void:
	if _instance:
		_instance._status_effect_container.remove_child(status_effect)
	
	if not keep_instance:
		status_effect.queue_free()
	
	if not keep_uid:
		_status_effects.erase(_status_effects.find_key(status_effect))


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
