extends CanvasLayer
class_name Tooltip

# ==============================================================================
static var _instance: Tooltip

static var max_length := 32
# ==============================================================================
@onready var panel: PanelContainer = %Panel
@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer
# ==============================================================================

func _init() -> void:
	_instance = self


func _ready() -> void:
	Tooltip.hide_text()


static func show_text(text: String) -> void:
	_instance.rich_text_label.text = text.strip_edges()
	
	_instance.panel.reset_size.call_deferred()
	
	_instance.animation_player.play("show")
	_instance.animation_player.seek(0)


static func hide_text() -> void:
	_instance.animation_player.play("hide")


static func limit_line_length(text: String, max_line_length: int) -> String:
	if text.length() <= max_line_length:
		return text
	
	var i := 0
	var line_length := 0
	var last_space := -1
	var bullet := false
	while i < text.length():
		var c := text[i]
		
		line_length += 1
		
		match c:
			"\n":
				line_length = 0
				last_space = -1
				bullet = false
			" " when i > 0 and text[i - 1] != "•":
				last_space = i
			"•": # U+2022
				bullet = true
				line_length -= 2
		
		if line_length > max_line_length:
			if last_space < 0:
				var added_sequence := "\n"
				if bullet:
					added_sequence += "  "
				text = text.insert(i + 1, added_sequence)
				i += added_sequence.length()
			else:
				text[last_space] = "\n"
				i = last_space
				if bullet:
					text = text.insert(i + 1, "  ")
					i += 2
			
			last_space = -1
			line_length = 0
		
		i += 1
	
	return text


func _process(_delta: float) -> void:
	panel.position.x = panel.get_global_mouse_position().x - panel.size.x / 2
	panel.position.y = panel.get_global_mouse_position().y - panel.size.y - 2 + offset.y / scale.y
	
	panel.position = panel.position.clamp(Vector2.ZERO, get_viewport_size() / scale - panel.size)


func get_viewport_size() -> Vector2:
	return Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)
