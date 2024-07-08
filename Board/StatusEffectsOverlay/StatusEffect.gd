extends HBoxContainer
class_name StatusEffect

# ==============================================================================
enum Type {
	TURNS,
	CELLS_OPENED,
	SECONDS,
}
# ==============================================================================
var source: Collectible :
	set(value):
		if source == value:
			return
		
		source = value
		
		if not is_node_ready():
			await ready
		
		var atlas := AtlasTexture.new()
		atlas.atlas = source.get_atlas()
		atlas.region = source.get_atlas_region()
		
		var image := atlas.get_image()
		image.resize(8, 8, Image.INTERPOLATE_NEAREST)
		
		texture_rect.texture = ImageTexture.create_from_image(image)
var origin := 0
var duration := 0 :
	set(value):
		duration = value
		
		if not is_node_ready():
			await ready
		
		if duration <= 0:
			queue_free()
			return
		
		count_label.text = str(duration)
var type := Type.TURNS
var reset_on_mistake := false
var attribute: Object
var sort_order := -1

var _tween: Tween
# ==============================================================================
@onready var texture_rect: TextureRect = %TextureRect
@onready var count_label: Label = %CountLabel
# ==============================================================================

func _ready() -> void:
	if reset_on_mistake:
		EffectManager.connect_effect(func mistake(): duration = origin)
	
	match type:
		Type.TURNS:
			EffectManager.connect_effect(func turn(): duration -= 1)
		Type.CELLS_OPENED:
			EffectManager.connect_effect(func cell_open(_cell: Cell): duration -= 1)
		Type.SECONDS:
			if Board.can_run_timer():
				_tween = create_tween()
				_tween.set_loops()
				_tween.tween_interval(1)
				_tween.tween_callback(func(): duration -= 1)
			
			# bottom code is better but does not work in godot 4.2.2 due to bug (fixed in 4.3)
			EffectManager.connect_effect(_restart_tween, false, false, &"board_permissions_changed")
			#EffectManager.connect_effect(func board_permissions_changed():
				#_restart_tween()
			#)


func _restart_tween() -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_loops()
	_tween.tween_interval(1)
	_tween.tween_callback(func(): duration -= 1)


static func create(uid: String = "") -> Initializer:
	var instance: StatusEffect = ResourceLoader.load("res://Board/StatusEffectsOverlay/StatusEffect.tscn").instantiate()
	
	return Initializer.new(instance, uid)


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
	
	func set_origin(origin: int = _status_effect.count) -> Initializer:
		_status_effect.origin = origin
		return self
	
	func set_type(type: StatusEffect.Type) -> Initializer:
		_status_effect.type = type
		return self
	
	func set_turns(turns: int = _status_effect.count) -> Initializer:
		_status_effect.count = turns
		return set_type(Type.TURNS)
	
	func set_cells(cells: int = _status_effect.count) -> Initializer:
		_status_effect.count = cells
		return set_type(Type.CELLS_OPENED)
	
	func set_seconds(seconds: int = _status_effect.count) -> Initializer:
		_status_effect.duration = seconds
		return set_type(Type.SECONDS)
	
	func set_attribute(attribute: Object) -> Initializer:
		_status_effect.attribute = attribute
		return self
	
	func set_reset_on_mistake(reset_on_mistake: bool = true) -> Initializer:
		_status_effect.reset_on_mistake = reset_on_mistake
		return self
	
	func set_source(source: Collectible) -> Initializer:
		_status_effect.source = source
		return self
	
	func start() -> StatusEffect:
		(func(): free()).call_deferred() # free.call_deferred() creates errors for some reason
		StatusEffectsOverlay.add_status_effect(_status_effect, uid)
		return _status_effect
