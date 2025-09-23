@tool
@abstract
extends TextureRect
class_name CellObjectTextureRectBase

# ==============================================================================
@onready var _tooltip_grabber: TooltipGrabber = null :
	set(value):
		_tooltip_grabber = value
		
		if value:
			value.about_to_show.connect(_on_tooltip_grabber_about_to_show)
# ==============================================================================

func _ready() -> void:
	for child in get_children():
		if child is TooltipGrabber:
			_tooltip_grabber = child


func _update() -> void:
	if not is_node_ready():
		await ready
	
	visible = _is_visible()
	
	if visible:
		texture = _get_texture()
		material = _get_material()
		modulate = _get_modulate()
		
		if _tooltip_grabber:
			_tooltip_grabber.enabled = _has_annotation_text() or Engine.is_editor_hint()
	else:
		texture = null
		material = null
		modulate = Color.WHITE
		
		if _tooltip_grabber:
			_tooltip_grabber.enabled = Engine.is_editor_hint()


## Virtual method. Should return whether the object is visible.
func _is_visible() -> bool:
	return true


## Virtual method. Should return the texture to be rendered.
@abstract func _get_texture() -> Texture2D


## Virtual method. Should return the [Material] to be used in rendering.
func _get_material() -> Material:
	return null


## Virtual method. Should return the modulation of the texture to use in rendering.
func _get_modulate() -> Color:
	return Color.WHITE


## Virtual method. Should return whether the object has annotation text.
func _has_annotation_text() -> bool:
	return true


## Virtual method. Should return the object's annotation text.
func _get_annotation_text() -> String:
	return ""


func _on_tooltip_grabber_about_to_show() -> void:
	_tooltip_grabber.text = _get_annotation_text()


func _validate_property(property: Dictionary) -> void:
	match property.name:
		&"texture":
			property.usage |= PROPERTY_USAGE_READ_ONLY
