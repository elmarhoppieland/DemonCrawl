extends Control
class_name MasteryAchievedPopup

# ==============================================================================
const SCENE := "res://Engine/Resources/Singletons/MasteryAchievedPopup.tscn"
# ==============================================================================
@onready var _mastery_display: MasteryDisplay = %MasteryDisplay
# ==============================================================================

static func show_mastery(mastery_data: MasteryInstanceData) -> void:
	var mastery := mastery_data.create()
	mastery.active = false
	var instance: MasteryAchievedPopup = load(SCENE).instantiate()
	instance._mastery_display.mastery = mastery
	await DCPopup.popup_show_instance(instance)
