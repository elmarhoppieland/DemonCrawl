@tool
extends Control
class_name CollectibleDisplay

# ==============================================================================
@export var _collectible: Collectible : set = set_collectible
# ==============================================================================
var _hovered := false
# ==============================================================================
@onready var _bg_rect: ColorRect = %BGRect
@onready var _collectible_texture: TextureRect = %CollectibleTexture
@onready var _tooltip_grabber: TooltipGrabber = %TooltipGrabber
# ==============================================================================
signal interacted()
# ==============================================================================

func _enter_tree() -> void:
	mouse_entered.connect(func() -> void:
		_hovered = true
		
		if not _collectible or not _collectible.can_use():
			return
		if not is_node_ready():
			await ready
		
		create_tween().tween_property(_bg_rect, "color:a", _collectible.get_texture_bg_color().a, 0.1).from(_collectible.get_texture_bg_color().a * 0.5)
	)
	mouse_exited.connect(func() -> void:
		_hovered = false
		
		if not _collectible or is_equal_approx(_bg_rect.color.a, _collectible.get_texture_bg_color().a * 0.5):
			return
		if not is_node_ready():
			await ready
		
		create_tween().tween_property(_bg_rect, "color:a", _collectible.get_texture_bg_color().a * 0.5, 0.1).from(_collectible.get_texture_bg_color().a)
	)


func _get_minimum_size() -> Vector2:
	if not is_node_ready():
		ready.connect(func() -> void: minimum_size_changed.emit(), CONNECT_ONE_SHOT)
		return Vector2.ZERO
	return _collectible_texture.get_minimum_size()


func set_collectible(collectible: Collectible) -> void:
	_collectible = collectible
	
	if not is_node_ready():
		await ready
	
	_collectible_texture.texture = collectible
	if collectible:
		_bg_rect.color = collectible.get_texture_bg_color()
		if not _hovered:
			_bg_rect.color.a /= 2
		_tooltip_grabber.text = collectible.get_annotation_text()
	else:
		_bg_rect.color = Color.TRANSPARENT
		_tooltip_grabber.text = ""


static func create(collectible: Collectible) -> CollectibleDisplay:
	var display := load("res://Resources/Scenes/CollectibleDisplay.tscn").instantiate() as CollectibleDisplay
	display.set_collectible(collectible)
	return display


func _on_interacted() -> void:
	if _collectible.can_use():
		_collectible._use()
	interacted.emit()
