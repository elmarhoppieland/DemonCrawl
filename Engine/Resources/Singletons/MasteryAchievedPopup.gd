extends DCPopup
class_name MasteryAchievedPopup

# ==============================================================================
@onready var _mastery_display: LargeCollectibleDisplay = %MasteryDisplay
# ==============================================================================

func show_mastery(mastery: Mastery) -> void:
	while _popup_visible:
		await popup_hidden
	
	_mastery_display.texture = mastery.create_icon()
	_mastery_display.description_text = mastery.get_display_name()
	_mastery_display.description_subtext = mastery.get_description_text()
	popup_show()
	await popup_hidden
