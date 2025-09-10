extends Control
class_name MasteryAchievedPopup

# ==============================================================================
const SCENE := "res://Engine/Resources/Singletons/MasteryAchievedPopup.tscn"
# ==============================================================================
var _mastery_display: MasteryDisplay :
	get:
		if not _mastery_display:
			_mastery_display = get_node_or_null("%MasteryDisplay")
		return _mastery_display
# ==============================================================================

static func show_mastery(mastery_data: MasteryInstanceData) -> void:
	var mastery := mastery_data.create()
	mastery.active = false
	var instance: MasteryAchievedPopup = load(SCENE).instantiate()
	instance._mastery_display.mastery = mastery
	await DCPopup.popup_show_instance(instance)
	instance.queue_free()
