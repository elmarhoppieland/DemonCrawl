@tool
extends Frame
class_name BeyondEmblemDisplay

# ==============================================================================
@export var emblem: EmblemData = null :
	set(value):
		emblem = value
		
		if not is_node_ready():
			await ready
		
		if not value:
			_emblem_texture.texture = null
			_tooltip_grabber.text = ""
			_tooltip_grabber.subtext = ""
			return
		
		_emblem_texture.texture = value.icon
		
		_tooltip_grabber.text = tr(value.name).to_upper()
		_tooltip_grabber.text_color = EmblemObject.TITLE_COLOR
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
			_emblem_texture.modulate.a = 0.5
		else:
			_count_label.show()
			_grabber.enabled = true
			_tooltip_grabber.enabled = true
			_emblem_texture.modulate.a = 1.0
# ==============================================================================
@onready var _grabber: Grabber = %Grabber
@onready var _emblem_texture: TextureRect = %EmblemTexture
@onready var _count_label: Label = %CountLabel
@onready var _tooltip_grabber: TooltipGrabber = %TooltipGrabber
# ==============================================================================
