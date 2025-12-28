extends Grabber
class_name CheckmarkGrabber

# ==============================================================================
static var _groups := {}
# ==============================================================================
@export var parent := ^"../.."
# ==============================================================================
var margin_container := MarginContainer.new()
var texture_rect := TextureRect.new()
# ==============================================================================

func _ready() -> void:
	super()
	
	texture_rect.texture = IconManager.get_icon_data("icons/checkmark").create_texture()
	
	texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_END | Control.SIZE_EXPAND
	texture_rect.size_flags_vertical = Control.SIZE_SHRINK_END | Control.SIZE_EXPAND
	
	margin_container.add_theme_constant_override("margin_right", -3)
	margin_container.add_theme_constant_override("margin_bottom", -2)
	margin_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin_container.hide()
	
	margin_container.add_child(texture_rect)
	control.add_child.call_deferred(margin_container)
	
	if get_node(parent) in _groups:
		_groups[get_node(parent)].append(self)
	else:
		_groups[get_node(parent)] = [self]


func interact() -> void:
	for grabber: CheckmarkGrabber in _groups[get_node(parent)]:
		grabber.margin_container.hide()
	
	margin_container.show()


func _exit_tree() -> void:
	_groups[get_node(parent)].erase(self)
