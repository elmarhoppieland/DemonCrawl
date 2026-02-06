@tool
extends MarginContainer
class_name DebugToolGlintDetails


# ==============================================================================
@export var glint: GlintData :
	set(value):
		glint = value
		
		if not is_node_ready():
			await ready
		
		if value:
			_title_label.text = value.name
			_texture_rect.texture = value.icon
			_tooltip_grabber.text = value.name
			_tooltip_grabber.subtext = value.get_description()
			_tooltip_grabber.text_color = GlintObject.TITLE_COLOR
			_tooltip_grabber.max_line_length = GlintObject.MAX_LINE_LENGTH
			
			update_count_label()
# ==============================================================================
@onready var _title_label: Label = %TitleLabel
@onready var _current_count_label: Label = %CurrentCountLabel
@onready var _texture_rect: TextureRect = %TextureRect
@onready var _tooltip_grabber: TooltipGrabber = %TooltipGrabber
# ==============================================================================

func _ready() -> void:
	Codex.glints_changed.connect(update_count_label)


func _get_overlay() -> DebugToolsOverlay:
	var base := get_parent()
	while base != null and base is not DebugToolsOverlay:
		base = base.get_parent()
	return base


func update_count_label() -> void:
	_current_count_label.text = "In Inventory: %d" % Codex.get_glints(glint)


func _on_add_to_inventory_button_pressed() -> void:
	Codex.gain_glint(glint)


func _on_bind_add_to_inventory_button_pressed() -> void:
	_get_overlay().bind_action(Codex.gain_glint.bind(glint))
