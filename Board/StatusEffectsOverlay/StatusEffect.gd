extends HBoxContainer
class_name StatusEffect

# ==============================================================================
enum Type {
	TURNS,
	CELLS_OPENED,
	SECONDS,
}
# ==============================================================================
var item: Item :
	set(value):
		if item == value:
			return
		
		item = value
		
		if not is_node_ready():
			await ready
		
		var atlas := AtlasTexture.new()
		atlas.atlas = item.get_atlas()
		atlas.region = item.get_atlas_region()
		
		var image := atlas.get_image()
		image.resize(8, 8, Image.INTERPOLATE_NEAREST)
		
		texture_rect.texture = ImageTexture.create_from_image(image)
var origin_count := 0
var count := 0 :
	set(value):
		count = value
		
		if not is_node_ready():
			await ready
		
		if count <= 0:
			queue_free()
			return
		
		count_label.text = str(count)
var type := Type.TURNS
var reset_on_mistake := false
var object: Object
# ==============================================================================
@onready var texture_rect: TextureRect = %TextureRect
@onready var count_label: Label = %CountLabel
# ==============================================================================

func _enter_tree() -> void:
	EffectManager.register_object(object)


func _exit_tree() -> void:
	EffectManager.unregister_object(object)


func _ready() -> void:
	if reset_on_mistake:
		EffectManager.connect_effect(func mistake(): count = origin_count)
	
	match type:
		Type.TURNS:
			EffectManager.connect_effect(func turn(): count -= 1)
		Type.CELLS_OPENED:
			EffectManager.connect_effect(func cell_open(_cell: Cell): count -= 1)
		Type.SECONDS:
			var tween := create_tween()
			tween.set_loops()
			tween.tween_interval(1)
			tween.tween_callback(func(): count -= 1)


static func create(id: String) -> Initializer:
	var instance: StatusEffect = ResourceLoader.load("res://Board/StatusEffectsOverlay/StatusEffect.tscn").instantiate()
	
	return Initializer.new(instance, id)


class Initializer extends Object:
	var _status_effect: StatusEffect :
		get:
			assert(get_stack()[1].function == start.get_method(), "The only way to obtain a reference to the StatusEffect is via finish().")
			return _status_effect
	var id := ""
	
	func _init(object: StatusEffect, _id: String) -> void:
		_status_effect = object
		id = _id
	
	func set_count(count: int, origin: bool = true) -> Initializer:
		_status_effect.count = count
		if origin:
			set_origin_count()
		return self
	
	func set_origin_count(origin_count: int = _status_effect.count) -> Initializer:
		_status_effect.origin_count = origin_count
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
		_status_effect.count = seconds
		return set_type(Type.SECONDS)
	
	func set_object(object: Object) -> Initializer:
		_status_effect.object = object
		return self
	
	func set_reset_on_mistake(reset_on_mistake: bool = true) -> Initializer:
		_status_effect.reset_on_mistake = reset_on_mistake
		return self
	
	func start() -> StatusEffect:
		(func(): free()).call_deferred() # free.call_deferred() creates errors for some reason
		StatusEffectsOverlay.add_status_effect(_status_effect, id)
		return _status_effect
