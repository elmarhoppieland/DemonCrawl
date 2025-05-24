@tool
extends Control
class_name CollectibleDisplay

# ==============================================================================
@export var collectible: Collectible :
	set(value):
		if collectible and collectible.changed.is_connected(_update):
			collectible.changed.disconnect(_update)
		
		collectible = value
		
		if not is_node_ready():
			await ready
		
		_collectible_texture.texture = value
		_update()
		if value:
			value.changed.connect(_update)
@export_group("Progress", "progress_")
@export var progress_full_color := Color("10df80")
@export var progress_partial_color := Color("f7ce4f")
# ==============================================================================
var _hovered := false

var _blink_tween: Tween
# ==============================================================================
@onready var _bg_rect: ColorRect = %BGRect
@onready var _collectible_texture: TextureRect = %CollectibleTexture
@onready var _progress_bar: ProgressBar = %ProgressBar
@onready var _tooltip_grabber: TooltipGrabber = %TooltipGrabber
# ==============================================================================
signal interacted()
# ==============================================================================

func _enter_tree() -> void:
	mouse_entered.connect(func() -> void:
		_hovered = true
		
		if not collectible:
			return
		if not collectible.is_active():
			return
		if not is_node_ready():
			await ready
		
		create_tween().tween_property(_bg_rect, "color:a", collectible.get_texture_bg_color().a, 0.1).from(collectible.get_texture_bg_color().a * 0.5)
	)
	mouse_exited.connect(func() -> void:
		_hovered = false
		
		if not collectible:
			return
		if is_equal_approx(_bg_rect.color.a, collectible.get_texture_bg_color().a * 0.5):
			_bg_rect.color.a = collectible.get_texture_bg_color().a * 0.5
			return
		if not collectible.is_active():
			return
		if not is_node_ready():
			await ready
		
		create_tween().tween_property(_bg_rect, "color:a", collectible.get_texture_bg_color().a * 0.5, 0.1).from(collectible.get_texture_bg_color().a)
	)


func _get_minimum_size() -> Vector2:
	if not is_node_ready():
		if not ready.is_connected(update_minimum_size):
			ready.connect(update_minimum_size, CONNECT_ONE_SHOT)
		return Vector2.ZERO
	return _collectible_texture.get_minimum_size()


func _update() -> void:
	if not is_node_ready():
		await ready
	
	if not collectible:
		_bg_rect.color = Color.TRANSPARENT
		_tooltip_grabber.text = ""
		_progress_bar.hide()
		
		if _blink_tween:
			_blink_tween.kill()
			_blink_tween = null
		
		_collectible_texture.material.set_shader_parameter("glow", 0)
		return
	
	_bg_rect.color = collectible.get_texture_bg_color()
	if not _hovered or not collectible.is_active():
		_bg_rect.color.a /= 2
	_tooltip_grabber.text = collectible.get_annotation_text()
	
	_progress_bar.visible = collectible.has_progress_bar()
	if _progress_bar.visible:
		var progress := collectible.get_progress()
		var max_progress := collectible.get_max_progress()
		_progress_bar.value = progress
		_progress_bar.max_value = max_progress
		_progress_bar.modulate = progress_full_color if progress == max_progress else progress_partial_color
	
	if not collectible.is_active():
		_collectible_texture.material.set_shader_parameter("glow", 0)
		return
	
	if not collectible.is_blinking():
		if _blink_tween:
			_blink_tween.kill()
			_blink_tween = null
		_collectible_texture.material.set_shader_parameter("glow", 0)
	elif not _blink_tween:
		const GLOW_DURATION := 0.4
		const GLOW_WAIT := 0.4
		
		var shader := _collectible_texture.material as ShaderMaterial
		
		_blink_tween = create_tween().set_loops()
		_blink_tween.tween_method(func(glow: float) -> void:
			shader.set_shader_parameter("glow", glow)
		, 0.0, 1.0, GLOW_DURATION)
		_blink_tween.tween_method(func(glow: float) -> void:
			shader.set_shader_parameter("glow", glow)
		, 1.0, 0.0, GLOW_DURATION)
		_blink_tween.tween_interval(GLOW_WAIT)


@warning_ignore("shadowed_variable")
static func create(collectible: Collectible) -> CollectibleDisplay:
	var display := load("res://Engine/Resources/Scenes/CollectibleDisplay.tscn").instantiate() as CollectibleDisplay
	display.collectible = collectible
	return display


func _on_interacted() -> void:
	if collectible:
		collectible.use()
		interacted.emit()
