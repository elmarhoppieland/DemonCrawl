@tool
extends TextureRect
class_name CellObjectTextureRect

# ==============================================================================
@export var _mode := Cell.Mode.HIDDEN
# ==============================================================================
var _delta_sum := 0.0
# ==============================================================================
@onready var _tooltip_grabber: TooltipGrabber = $TooltipGrabber
# ==============================================================================

func _ready() -> void:
	var cell := owner as Cell
	
	texture = cell.get_object()
	_mode = cell.get_mode()
	cell.object_changed.connect(func(object: CellObject) -> void:
		texture = object
		
		if object:
			material = object.get_material()
			#var palette := object.get_palette()
			#(material as ShaderMaterial).set_shader_parameter("palette_enabled", palette != null)
			#(material as ShaderMaterial).set_shader_parameter("palette", palette)
			
			_tooltip_grabber.enabled = object.has_annotation_text()
			_tooltip_grabber.text = object.get_annotation_text()
		else:
			#(material as ShaderMaterial).set_shader_parameter("palette_enabled", false)
			material = null
			
			_tooltip_grabber.enabled = false
		
		_update()
	)
	cell.mode_changed.connect(func(mode: Cell.Mode) -> void:
		_mode = mode
		_update()
	)
	_update()


func _process(delta: float) -> void:
	if texture and texture is CellObject:
		_delta_sum += delta
		#texture.animate(_delta_sum)


func _update() -> void:
	visible = _mode == Cell.Mode.VISIBLE


func get_2d_anchor() -> Node2D:
	return get_parent()
