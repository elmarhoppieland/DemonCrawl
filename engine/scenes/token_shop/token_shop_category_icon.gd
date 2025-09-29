@tool
extends TextureRect
class_name TokenShopCategoryIcon

# ==============================================================================
@export var category: TokenShopCategoryBase = null :
	set(value):
		category = value
		
		texture = value.get_icon() if value else null
		
		if not is_node_ready():
			await ready
		
		_focus_grabber.main = value == TokenShop.selected_category
		_tooltip_grabber.text = value.name if value else ""
# ==============================================================================
@onready var _focus_grabber: FocusGrabber = %FocusGrabber
@onready var _tooltip_grabber: TooltipGrabber = %TooltipGrabber
# ==============================================================================
signal interacted()
# ==============================================================================

func _ready() -> void:
	_tooltip_grabber.interacted.connect(func() -> void: interacted.emit())
