extends CanvasLayer
class_name Tooltip

# ==============================================================================
static var _instance: Tooltip
# ==============================================================================
@onready var panel: PanelContainer = %Panel
@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================

func _init() -> void:
	_instance = self


func _ready() -> void:
	Tooltip.hide_text()


@warning_ignore("shadowed_variable_base_class")
static func show_text(text: String, context: TooltipContext = null) -> void:
	if context:
		text = context.get_text(text)
	
	_instance.rich_text_label.text = text.strip_edges()
	
	_instance.panel.reset_size.call_deferred()
	
	_instance.animation_player.play("show")
	_instance.animation_player.seek(0)


static func hide_text() -> void:
	_instance.animation_player.play("hide")


static func limit_line_length(text: String, max_line_length: int) -> String:
	if text.length() <= max_line_length:
		return text
	
	return _LineLengthLimiter.new(text, max_line_length).get_result()


func _process(_delta: float) -> void:
	panel.position.x = panel.get_global_mouse_position().x - panel.size.x / 2
	panel.position.y = panel.get_global_mouse_position().y - panel.size.y - 2 + offset.y / scale.y
	
	panel.position = panel.position.clamp(Vector2.ZERO, get_viewport_size() / scale - panel.size)


func get_viewport_size() -> Vector2:
	return Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)


class _LineLengthLimiter:
	var text := ""
	var max_line_length := 0
	var result := ""
	var line_length := 0
	var word_buffer := ""
	var in_tag := false
	var in_bullet := false
	
	@warning_ignore("shadowed_variable")
	func _init(text: String, max_line_length: int) -> void:
		self.text = text
		self.max_line_length = max_line_length
	
	func get_result() -> String:
		result = ""
		line_length = 0
		word_buffer = ""
		in_tag = false
		in_bullet = false
		
		for c in text:
			match c:
				"]" when in_tag:
					in_tag = false
					result += c
				_ when in_tag:
					result += c
				" ":
					_add_word()
					result += c
					line_length += 1
				"\n":
					_add_word()
					result += c
					line_length = 0
					in_bullet = false
				"[":
					_add_word()
					result += c
					in_tag = true
				"•" when word_buffer.is_empty() and (result.is_empty() or result[-1] == "\n"):
					in_bullet = true
					result += c
				_:
					word_buffer += c
		
		_add_word()
		return result
	
	func _add_word() -> void:
		if word_buffer.is_empty():
			return
		
		if line_length + word_buffer.length() < max_line_length:
			result += word_buffer
			line_length += word_buffer.length()
			word_buffer = ""
			return
		
		result = result.rstrip(" ")
		if not result.is_empty():
			result += "\n"
		if in_bullet:
			result += "  "
		result += word_buffer
		line_length = word_buffer.length()
		if in_bullet:
			line_length += 2
		word_buffer = ""
