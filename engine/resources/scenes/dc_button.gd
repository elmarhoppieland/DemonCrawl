@tool
extends BaseButton
class_name DCButton

# ==============================================================================
enum TextOverrunBehavior {
	TRIM_NOTHING,
	TRIM_CHARACTERS,
	TRIM_WORDS,
	ELLIPSIS,
	WORD_ELLIPSIS
}
# ==============================================================================
@export var color := Color.WHITE :
	set(value):
		color = value
		if not is_node_ready():
			await ready
		_color_rect.color = value
		_panel.self_modulate = value
		_icon_rect.self_modulate = value
		_label.label_settings.font_color = value
@export var bg_color := Color.TRANSPARENT :
	set(value):
		bg_color = value
		if not is_node_ready():
			await ready
		_bg_rect.color = value

@export_category("Button")
@export_multiline var text := "" :
	set(value):
		text = value
		if not is_node_ready():
			await ready
		_label.text = value
		update_minimum_size()
@export var icon: Texture2D :
	set(value):
		if icon and icon.changed.is_connected(update_minimum_size):
			icon.changed.disconnect(update_minimum_size)
		icon = value
		if not is_node_ready():
			await ready
		_icon_rect.texture = value
		_icon_rect.visible = value != null
		update_minimum_size.call_deferred()
		if value:
			value.changed.connect(update_minimum_size, CONNECT_DEFERRED)
@export var flat := true

@export_group("Text Behavior")
@export_enum("Left", "Center", "Right") var alignment := 1 :
	set(value):
		alignment = value
		if not is_node_ready():
			await ready
		_label.horizontal_alignment = value as HorizontalAlignment
@export var text_overrun_behavior := TextOverrunBehavior.TRIM_NOTHING :
	set(value):
		text_overrun_behavior = value
		if not is_node_ready():
			await ready
		_label.text_overrun_behavior = value as TextServer.OverrunBehavior
		update_minimum_size()
@export var clip_text := false

@export_group("Icon Behavior")
@export_enum("Left:0", "Right:2") var icon_alignment := 0 :
	set(value):
		icon_alignment = value
		if not is_node_ready():
			await ready
		match value:
			HORIZONTAL_ALIGNMENT_LEFT:
				_label.move_to_front()
			HORIZONTAL_ALIGNMENT_RIGHT:
				_icon_rect.move_to_front()
@export_enum("Top", "Center", "Bottom") var vertical_icon_alignment := 1 :
	set(value):
		vertical_icon_alignment = value
		if not is_node_ready():
			await ready
		match value:
			VERTICAL_ALIGNMENT_TOP:
				_icon_rect.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			VERTICAL_ALIGNMENT_CENTER:
				_icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			VERTICAL_ALIGNMENT_BOTTOM:
				_icon_rect.size_flags_vertical = Control.SIZE_SHRINK_END
@export var expand_icon := false

@export_group("BiDi")
@export_enum("Auto", "Left-to-Right", "Right-to-Left", "Inherited") var text_direction := 0 :
	set(value):
		text_direction = value
		if not is_node_ready():
			await ready
		_label.text_direction = value as Control.TextDirection
		update_minimum_size()
@export var language := "" :
	set(value):
		language = value
		if not is_node_ready():
			await ready
		_label.language = value
		update_minimum_size()
# ==============================================================================
@onready var _icon_rect: TextureRect = %IconRect
@onready var _label: Label = %Label
@onready var _panel: PanelContainer = %PanelContainer
@onready var _color_rect: ColorRect = %ColorRect
@onready var _bg_rect: ColorRect = %BGRect
# ==============================================================================

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"flat", "clip_text", "expand_icon":
			property.usage |= PROPERTY_USAGE_READ_ONLY
		"language":
			property.hint = PROPERTY_HINT_LOCALE_ID


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	
	mouse_entered.connect(func() -> void:
		var tween := create_tween().set_parallel()
		tween.tween_property(_color_rect, "modulate:a", 1.0, 0.1).from(0.0)
		tween.tween_property(_label.label_settings, "font_color", Color.WHITE, 0.1).from(color)
		tween.tween_property(_icon_rect, "self_modulate", Color.WHITE, 0.1).from(color)
	)
	mouse_exited.connect(func() -> void:
		var tween := create_tween().set_parallel()
		tween.tween_property(_color_rect, "modulate:a", 0.0, 0.1).from(1.0)
		tween.tween_property(_label.label_settings, "font_color", color, 0.1).from(Color.WHITE)
		tween.tween_property(_icon_rect, "self_modulate", color, 0.1).from(Color.WHITE)
	)


func _get_minimum_size() -> Vector2:
	if not _panel:
		return Vector2.ZERO
	return _panel.get_minimum_size()
