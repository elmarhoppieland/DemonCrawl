@tool
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
		
		if _tooltip_grabber:
			_tooltip_grabber.enabled = _has_annotation_text() or Engine.is_editor_hint()
	else:
		texture = null
		material = null
		
		if _tooltip_grabber:
			_tooltip_grabber.enabled = Engine.is_editor_hint()


func _is_visible() -> bool:
	return true


func _get_texture() -> Texture2D:
	return null


func _get_material() -> Material:
	return null


func _has_annotation_text() -> bool:
	return true


func _get_annotation_text() -> String:
	return ""


func _on_tooltip_grabber_about_to_show() -> void:
	_tooltip_grabber.text = _get_annotation_text()


func _validate_property(property: Dictionary) -> void:
	match property.name:
		&"texture":
			property.usage |= PROPERTY_USAGE_READ_ONLY
