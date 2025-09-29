extends CanvasLayer
class_name GuiLayer

# ==============================================================================
static var _instance: GuiLayer : get = get_instance
# ==============================================================================

func _init() -> void:
	_instance = self


func _exit_tree() -> void:
	if _instance == self:
		_instance = null


func _ready() -> void:
	for child in get_children():
		if child is CanvasItem or child is CanvasLayer:
			child.hide()


static func get_instance() -> GuiLayer:
	return _instance


static func get_statbar() -> Statbar:
	return get_instance().get_node_or_null("Statbar")


static func get_orb_layer() -> OrbLayer:
	return get_instance().get_node_or_null("OrbLayer")


static func get_texture_tweener() -> TextureTweener:
	return get_instance().get_node_or_null("TextureTweener")


static func get_mastery_achieved_popup() -> MasteryAchievedPopup:
	return get_instance().get_node_or_null("MasteryAchievedPopup")
