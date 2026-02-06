@tool
extends Frame
class_name BeyondGlintDisplay

# ==============================================================================
@export var glint: GlintData = null :
	set(value):
		glint = value
		
		if not is_node_ready():
			await ready
		
		if not value:
			_glint_texture.texture = null
			_tooltip_grabber.text = ""
			_tooltip_grabber.subtext = ""
			return
		
		_glint_texture.texture = value.icon
		
		_tooltip_grabber.text = tr(value.name).to_upper()
		_tooltip_grabber.text_color = GlintObject.TITLE_COLOR
		_tooltip_grabber.subtext = value.get_description()
@export var count := 0 :
	set(value):
		count = value
		
		if not is_node_ready():
			await ready
		
		if value < 1000:
			_count_label.text = str(value)
		else:
			_count_label.text = str(value / 1000) + "K"
		
		if value == 0:
			_count_label.hide()
			_grabber.enabled = false
			_tooltip_grabber.enabled = false
			_glint_texture.modulate.a = 0.5
		else:
			_count_label.show()
			_grabber.enabled = true
			_tooltip_grabber.enabled = true
			_glint_texture.modulate.a = 1.0
# ==============================================================================
@onready var _grabber: Grabber = %Grabber
@onready var _glint_texture: TextureRect = %GlintTexture
@onready var _count_label: Label = %CountLabel
@onready var _tooltip_grabber: TooltipGrabber = %TooltipGrabber
# ==============================================================================
