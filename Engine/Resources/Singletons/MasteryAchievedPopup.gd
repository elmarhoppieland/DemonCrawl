extends DCPopup
class_name MasteryAchievedPopup

# ==============================================================================
@onready var _mastery_display: MasteryDisplay = %MasteryDisplay
# ==============================================================================

func show_mastery(mastery: MasteryInstanceData) -> void:
	while _popup_visible:
		await popup_hidden
	
	var instance := mastery.create()
	instance.active = false
	_mastery_display.mastery = instance
	_mastery_display.add_child(instance)
	
	popup_show()
	await popup_hidden
