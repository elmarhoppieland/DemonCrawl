extends CodeEdit
class_name CommandLine

# ==============================================================================
const CLASS_COLOR := Color(0.741176, 0.94902, 0.882353, 1)
# ==============================================================================
static var added_vars := {}
# ==============================================================================
@onready var command_line_feedback: RichTextLabel = %CommandLineFeedback
# ==============================================================================

func _ready() -> void:
	text_changed.connect(_text_changed)
	visibility_changed.connect(func(): command_line_feedback.visible = visible)
	
	for class_data in ProjectSettings.get_global_class_list():
		added_vars[class_data.class] = ResourceLoader.load(class_data.path)
		syntax_highlighter.add_member_keyword_color(class_data.class, CLASS_COLOR)


func _text_changed() -> void:
	if "\n" in text:
		text = text.replace("\n", "")
		_text_entered()
		clear()


func _text_entered() -> void:
	if text.is_empty():
		return
	
	var expression := Expression.new()
	var error := expression.parse(text, added_vars.keys())
	if error:
		command_line_feedback.text = "[color=red]There was an error parsing the command.[/color]"
		return
	
	var value = await expression.execute(added_vars.values(), self)
	if expression.has_execute_failed():
		command_line_feedback.text = "[color=red]There was an error executing the command: %s[/color]" % expression.get_error_text()
		Debug.log_event("Command '%s' failed: %s" % [text, expression.get_error_text()], Color.RED)
		return
	if not value is String:
		value = ">> " + str(value)
	
	command_line_feedback.text = value
	
	Debug.log_event("Executed command '%s'. Returned: %s" % [text, value], Color.YELLOW)


func next() -> String:
	get_tree().paused = false
	
	# we're waiting twice because the signal is called directly before _physics_process()
	# is called; waiting twice means we're pausing right before the second frame happens
	await get_tree().physics_frame
	await get_tree().process_frame
	
	get_tree().paused = true
	
	return "Advanced the world by 1 physics frame."


func overlay_select(path: String) -> String:
	if not path.begins_with("/root/"):
		path = "/root/" + path
	
	Debug.left_object = get_node(path)
	
	return "Set the left overlay to " + path + "."


func overlay_select_left(path: String) -> String:
	return overlay_select(path)


func overlay_select_right(path: String) -> String:
	match path:
		_:
			if not path.begins_with("/root/"):
				path = "/root/" + path
			
			Debug.right_object = get_node(path)
	
	return "Set the right overlay to " + path + "."


func inspect(keyword: String, side: String = "l") -> String:
	const KEYWORDS := {
		"player": "/root/QuestScene/QuestCanvas/Player"
	}
	
	keyword = keyword.to_lower()
	
	if not keyword in KEYWORDS:
		return "[color=red]Unknown keyword '%s'.[/color]" % keyword
	
	var path: String = KEYWORDS[keyword]
	var node := get_node_or_null(path)
	if not node:
		return "[color=red]The object with keyword '%s' is not in the scene tree.[/color]" % keyword
	
	match side:
		"l":
			Debug.left_object = node
		"r":
			Debug.right_object = node
		_:
			return "[color=red]Expected a side as the 2nd argument.[/color]"
	
	return "Set the %s overlay to %s." % ["left" if side == "l" else "right", keyword]


func inspectr(keyword: String) -> String:
	return inspect(keyword, "r")
