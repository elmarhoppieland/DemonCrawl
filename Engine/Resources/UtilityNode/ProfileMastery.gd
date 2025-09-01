@tool
extends TextureRect
class_name ProfileMastery

# ==============================================================================
var _tooltip_grabber := TooltipGrabber.new()
# ==============================================================================

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	add_child(_tooltip_grabber)
	_update()
	Codex.selected_mastery_changed.connect(_update)


func _update() -> void:
	if Codex.selected_mastery:
		texture = Codex.selected_mastery.create_temp().create_icon()
		_tooltip_grabber.text = Codex.selected_mastery.create_temp().get_display_name()
		_tooltip_grabber.subtext = Codex.selected_mastery.create_temp().get_description_text()
	else:
		texture = IconManager.get_icon_data("mastery/none").create_texture()
		_tooltip_grabber.text = tr("mastery.none")
