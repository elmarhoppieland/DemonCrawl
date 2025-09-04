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
		var mastery := Codex.selected_mastery.instantiate(Codex.get_selectable_mastery_level(Codex.selected_mastery))
		texture = mastery.get_icon()
		_tooltip_grabber.text = mastery.get_name_text()
		_tooltip_grabber.subtext = mastery.get_description_text()
	else:
		texture = IconManager.get_icon_data("mastery/none").create_texture()
		_tooltip_grabber.text = tr("mastery.none")
