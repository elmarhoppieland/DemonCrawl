@tool
extends TextureRect
class_name CellObjectTextureRect

# ==============================================================================
@export var object: CellObject = null :
	set(value):
		object = value
		
		texture = value.get_texture() if value else null
		
		_update()
# ==============================================================================
@onready var _tooltip_grabber: TooltipGrabber = null :
	set(value):
		_tooltip_grabber = value
		
		if value:
			value.about_to_show.connect(_on_tooltip_grabber_about_to_show)
# ==============================================================================

func _ready() -> void:
	_tooltip_grabber = get_node_or_null("TooltipGrabber")


func _update() -> void:
	if object:
		material = object.get_material()
		
		if _tooltip_grabber:
			_tooltip_grabber.enabled = object.has_annotation_text()
	else:
		material = null
		
		if _tooltip_grabber:
			_tooltip_grabber.enabled = false


func get_2d_anchor() -> Node2D:
	return get_parent()


func _validate_property(property: Dictionary) -> void:
	match property.name:
		&"texture":
			property.usage |= PROPERTY_USAGE_READ_ONLY


func _on_tooltip_grabber_about_to_show() -> void:
	if not object:
		_tooltip_grabber.text = ""
		return
	
	_tooltip_grabber.text = object.get_annotation_text()
