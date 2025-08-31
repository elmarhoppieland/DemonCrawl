@tool
extends TextureRect
class_name CellObjectTextureRect

# ==============================================================================
var _cell: CellData = null :
	set(value):
		if _cell and _cell.changed.is_connected(_update):
			_cell.changed.disconnect(_update)
		
		_cell = value
		
		_update()
		if value:
			value.changed.connect(_update)
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


func _enter_tree() -> void:
	var cell := get_parent()
	while cell != null and cell is not Cell:
		cell = cell.get_parent()
	if cell == null:
		return
	
	_set_cell(cell)
	cell.data_assigned.connect(_set_cell.bind(cell))


func _exit_tree() -> void:
	var cell := get_parent()
	while cell != null and cell is not Cell:
		cell = cell.get_parent()
	if cell == null:
		return
	
	cell.data_assigned.disconnect(_set_cell.bind(cell))


func _set_cell(cell: Cell) -> void:
	_cell = cell.get_data()


func _update() -> void:
	if not _cell:
		return
	
	visible = _cell.is_visible()
	
	if _cell.is_occupied():
		texture = _cell.get_object().get_texture()
		material = _cell.get_object().get_material()
		
		print(_cell.get_object().has_annotation_text())
		if _tooltip_grabber:
			_tooltip_grabber.enabled = _cell.get_object().has_annotation_text()
	else:
		texture = null
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
	if not _cell or _cell.is_empty():
		_tooltip_grabber.text = ""
		return
	
	_tooltip_grabber.text = _cell.get_object().get_annotation_text()
