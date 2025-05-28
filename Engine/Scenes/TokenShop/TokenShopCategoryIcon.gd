@tool
extends TextureRect
class_name TokenShopCategoryIcon

# ==============================================================================
@export var category: TokenShopCategory = null :
	set(value):
		category = value
		
		if not value:
			texture = null
			_tooltip_grabber.text = ""
			return
		
		texture = value.icon
		
		if not is_node_ready():
			await ready
		
		_tooltip_grabber.text = value.name
# ==============================================================================
@onready var _focus_grabber: FocusGrabber = %FocusGrabber
@onready var _tooltip_grabber: TooltipGrabber = %TooltipGrabber
# ==============================================================================
signal interacted()
# ==============================================================================

func _ready() -> void:
	_focus_grabber.main = get_index() == 0
	
	_tooltip_grabber.interacted.connect(func() -> void: interacted.emit())
