extends DCPopup
class_name MasteryAchievedPopup

# ==============================================================================
@onready var _mastery_texture_rect: TextureRect = %MasteryTextureRect
@onready var _tooltip_grabber: TooltipGrabber = %TooltipGrabber
# ==============================================================================

func show_mastery(mastery: Mastery.MasteryData) -> void:
	while _popup_visible:
		await popup_hidden
	
	_mastery_texture_rect.texture = mastery.create_temp().create_icon()
	_tooltip_grabber.text = mastery.create_temp().get_display_name()
	_tooltip_grabber.subtext = mastery.create_temp().get_description_text()
	popup_show()
	await popup_hidden
