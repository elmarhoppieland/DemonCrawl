@tool
extends MarginContainer
class_name StatusEffectDisplay

# ==============================================================================
const TIMER_SECONDS_COLOR := Color(0.972549, 0.705882, 0.0705882, 1)
# ==============================================================================
@export var status_effect: StatusEffect = null :
	set(value):
		if status_effect and status_effect.changed.is_connected(_update):
			status_effect.changed.disconnect(_update)
		
		status_effect = value
		
		if not is_node_ready():
			await ready
		
		_update()
		if value:
			value.changed.connect(_update)
# ==============================================================================
@onready var _texture_rect: TextureRect = %TextureRect
@onready var _label: Label = %Label
# ==============================================================================

func _update() -> void:
	if status_effect:
		_texture_rect.texture = status_effect.get_texture()
		_label.text = str(status_effect.get_duration())
		
		if status_effect.get_type() == StatusEffect.Type.SECONDS:
			_label.text += "s"
			_label.label_settings.font_color = TIMER_SECONDS_COLOR
		else:
			_label.label_settings.font_color = Color.WHITE
	else:
		_texture_rect.texture = null
		_label.text = ""
