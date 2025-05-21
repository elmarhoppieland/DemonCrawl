extends HBoxContainer
class_name StatusEffect

# ==============================================================================
enum Type {
	TURNS,
	CELLS_OPENED,
	SECONDS,
}
# ==============================================================================
var texture: Texture2D :
	set(value):
		if texture == value:
			return
		
		texture = value
		
		if not is_node_ready():
			await ready
		
		texture_rect.texture = value
var source := ""
var origin := 0
var duration := 0 :
	set(value):
		duration = value
		
		if not is_node_ready():
			await ready
		
		if duration <= 0:
			if attribute and attribute.has_method("end"):
				attribute.end()
			
			if looping:
				duration += origin
				return
			
			StatusEffectsOverlay.remove_status_effect(self)
			return
		
		count_label.text = str(duration)
var type := Type.TURNS
var reset_on_mistake := false
var attribute: Object
var sort_order := -1
var looping := false

var _tween: Tween
# ==============================================================================
@onready var texture_rect: TextureRect = %TextureRect
@onready var count_label: Label = %CountLabel
# ==============================================================================

func _ready() -> void:
	# NOTE: we need to specify the effect param each time because a bug in godot 4.2 makes get_method() not work
	# after updating to 4.3 we can remove these
	
	if reset_on_mistake:
		Effects.Signals.mistake.connect(func() -> void:
			duration = origin
		)
	
	match type:
		Type.TURNS:
			Effects.Signals.turn.connect(func() -> void:
				duration -= 1
			)
		Type.CELLS_OPENED:
			Effects.Signals.cell_open.connect(func(_cell: Cell) -> void:
				duration -= 1
			)
		Type.SECONDS:
			if Stage.get_current().can_run_timer():
				_restart_tween()
			
			Effects.Signals.stage_permissions_changed.connect(func() -> void:
				if Stage.get_current().can_run_timer().can_run_timer():
					_restart_tween()
				elif _tween:
					_tween.kill()
			)


func get_uid() -> String:
	return StatusEffectsOverlay._status_effects.find_key(self)


func to_dict() -> Dictionary:
	return {
		"duration": duration,
		"origin": origin,
		"type": type,
		"looping": looping,
		"reset_on_mistake": reset_on_mistake,
		"sort_order": sort_order,
		"source": source,
		"attribute": attribute
	}


func _restart_tween() -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_loops()
	_tween.tween_interval(1)
	_tween.tween_callback(func(): duration -= 1)


static func create(uid: String = "") -> Initializer:
	var instance: StatusEffect = load("res://Engine/Resources/Scenes/StatusEffect.tscn").instantiate()
	
	return Initializer.new(instance, uid)


static func from_dict(dict: Dictionary) -> StatusEffect:
	var instance: StatusEffect = load("res://Engine/Resources/Scenes/StatusEffect.tscn").instantiate()
	
	instance.duration = dict.duration
	instance.origin = dict.origin
	instance.type = dict.type
	instance.looping = dict.looping
	instance.reset_on_mistake = dict.reset_on_mistake
	instance.sort_order = dict.sort_order
	instance.source = dict.source
	instance.attribute = dict.attribute
	instance.texture = ItemData.from_path(dict.source).get_small_icon()
	
	return instance


class Initializer extends Object:
	var _status_effect: StatusEffect
	var uid := ""
	
	func _init(object: StatusEffect, _uid: String) -> void:
		_status_effect = object
		uid = _uid
	
	func set_duration(duration: int, origin: bool = true) -> Initializer:
		_status_effect.duration = duration
		if origin:
			set_origin()
		return self
	
	func set_origin(origin: int = _status_effect.duration) -> Initializer:
		_status_effect.origin = origin
		return self
	
	func set_type(type: StatusEffect.Type) -> Initializer:
		_status_effect.type = type
		return self
	
	func set_turns(turns: int = _status_effect.duration, origin: bool = turns != _status_effect.duration) -> Initializer:
		return set_duration(turns, origin).set_type(Type.TURNS)
	
	func set_cells(cells: int = _status_effect.duration, origin: bool = cells != _status_effect.duration) -> Initializer:
		return set_duration(cells, origin).set_type(Type.CELLS_OPENED)
	
	func set_seconds(seconds: int = _status_effect.duration, origin: bool = seconds != _status_effect.duration) -> Initializer:
		return set_duration(seconds, origin).set_type(Type.SECONDS)
	
	func set_attribute(attribute: Object) -> Initializer:
		_status_effect.attribute = attribute
		return self
	
	func set_reset_on_mistake(reset_on_mistake: bool = true) -> Initializer:
		_status_effect.reset_on_mistake = reset_on_mistake
		return self
	
	func set_source(source: Collectible) -> Initializer:
		var atlas := AtlasTexture.new()
		atlas.atlas = source.get_atlas()
		atlas.region = source.get_atlas_region()
		
		var image := atlas.get_image()
		image.resize(8, 8, Image.INTERPOLATE_NEAREST)
		
		_status_effect.texture = ImageTexture.create_from_image(image)
		_status_effect.source = source.get_path()
		return self
	
	func start() -> StatusEffect:
		(func(): free()).call_deferred() # free.call_deferred() creates errors for some reason
		StatusEffectsOverlay.add_status_effect(_status_effect, uid)
		return _status_effect
