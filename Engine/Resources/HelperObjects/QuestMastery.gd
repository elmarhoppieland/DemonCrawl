@tool
extends TextureRect
class_name QuestMastery

# ==============================================================================
@export var quest: Quest = null :
	set(value):
		quest = value
		_update()
# ==============================================================================
var _tooltip_grabber := TooltipGrabber.new()
# ==============================================================================

func _validate_property(property: Dictionary) -> void:
	match property.name:
		&"texture":
			property.usage |= PROPERTY_USAGE_READ_ONLY


func _ready() -> void:
	add_child(_tooltip_grabber)
	
	_update()
	Quest.current_changed.connect(_update)


func _update() -> void:
	if not quest:
		if Quest.has_current() and Quest.get_current().get_mastery():
			texture = Quest.get_current().get_mastery().create_icon()
			_tooltip_grabber.text = Quest.get_current().get_mastery().get_display_name()
			_tooltip_grabber.subtext = Quest.get_current().get_mastery().get_description_text()
			return
		
		texture = null
		return
	
	if quest.get_mastery():
		texture = quest.get_mastery().create_icon()
		_tooltip_grabber.text = quest.get_mastery().get_display_name()
		_tooltip_grabber.subtext = quest.get_mastery().get_description_text()
		return
	
	texture = null
