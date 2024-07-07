extends CanvasLayer
class_name Debug

## Singleton for debugging purposes.

# ==============================================================================
enum DebugSide {
	LEFT,
	RIGHT
}
# ==============================================================================
const META_PREFIX := "debug_"
const DEBUG_FILE_PATH := "user://overlay.debug"

const LOG_DIR := "user://logs"
const LOG_FILE_PATH_BASE := LOG_DIR + "/log%d.txt"
# ==============================================================================
static var max_log_count: int = SavesManager.get_setting("max_log_count", Debug, 100)

static var all_objects: Array[Object] = []
static var left_object: Object
static var right_object: Object

static var _instance: Debug

static var _log_queue := ""
static var _log_file_idx := -1

var _debug_lines_left: Array[Dictionary] = []
var _debug_lines_right: Array[Dictionary] = []
# ==============================================================================
@onready var debug_label_left: Label = %DebugLabelLeft
@onready var debug_label_right: Label = %DebugLabelRight
@onready var command_line: TextEdit = %CommandLine
# ==============================================================================

func _init() -> void:
	assert(not _instance, "Can only have one instance of Singleton '%s'. Use static functions instead." % name)
	
	_instance = self


func _ready() -> void:
	debug_label_left.hide()
	debug_label_right.hide()
	command_line.hide()
	
	left_object = get_tree().current_scene
	
	Debug._init_log_file()
	Eternity.saved.connect(Debug._flush_log_file)
	
	Eternity.saved.connect(func():
		Debug.log_event("Saved the current data to disk (to path '%s')" % Eternity.path, Color.DARK_SALMON)
	)
	Eternity.loaded.connect(func():
		Debug.log_event("Loaded from the save at path '%s'" % Eternity.path, Color.CORAL)
	)
	
	update()


func _process(_delta: float) -> void:
	if debug_label_left.visible or debug_label_right.visible:
		update()
	
	_handle_toggle()


func _exit_tree() -> void:
	Debug.log_event("Closing DemonCrawl", Color.GRAY)
	Debug._flush_log_file()


## Logs [code]message[/code], adding a new line in the log file, and if
## [code]print_to_console[/code] is [code]true[/code] and this is a debug build,
## prints to the console.
static func log_event(message: String, color: Color = Color.AQUA, print_to_console: bool = true) -> void:
	if OS.is_debug_build() and print_to_console:
		print_rich("[color=#%s]%s[/color]" % [color.to_html(),  message])
	
	if not _log_queue.is_empty():
		_log_queue += "\n"
	_log_queue += "[%s] %s" % [Time.get_datetime_string_from_system().replace("T", " @ "), message]


## Logs [code]error[/code], and prints an error message.
static func log_error(error: String) -> void:
	var stack := get_stack()
	
	if stack.size() > 1 and "function" in stack[1]:
		var method: String = stack[1].function
		var message := "Error occurred in method '%s': %s" % [method, error]
		push_error(message)
		log_event(message, Color.RED)
	else:
		push_error(error)
		log_event("Error: " + error, Color.RED)


static func log_warning(warning: String) -> void:
	var stack := get_stack()
	
	if stack.size() > 1 and "function" in stack[1]:
		var method: String = stack[1].function
		var message := "Warning in method '%s': %s" % [method, warning]
		push_warning(message)
		log_event(message, Color.YELLOW)
	else:
		push_warning(warning)
		log_event("Warning: " + warning, Color.YELLOW)


static func clear_overlay() -> void:
	_instance._debug_lines_left.clear()
	_instance._debug_lines_right.clear()


static func get_text(object: Object, round_floats: bool = true) -> String:
	if not object:
		return "(No Object Selected)"
	
	var text = ""
	
	if "name" in object and (object.name is String or object.name is StringName):
		text += object.name
	elif object is Resource:
		text += object.resource_path.get_file().get_basename()
	else:
		text += str(object)
	
	if not is_instance_valid(object):
		text += " (invalid)"
	
	text += "\n======================\n"
	
	for meta in object.get_meta_list():
		if not meta.begins_with(META_PREFIX):
			continue
		
		text += meta.trim_prefix(META_PREFIX).capitalize() + ": "
		
		var value = object.get_meta(meta)
		
		if value is Callable:
			value = value.call()
			if round_floats and typeof(value) in [TYPE_FLOAT, TYPE_VECTOR2, TYPE_VECTOR3, TYPE_VECTOR4]:
				value = round(value)
		
		text += str(value)
		
		text += "\n"
	
	return text


static func push_debug(object: Object, key: String, value: Variant) -> void:
	object.set_meta(META_PREFIX + key.to_snake_case(), value)
	if not object in all_objects:
		all_objects.append(object)


static func remove_debug(object: Object, key: String) -> void:
	object.remove_meta(META_PREFIX + key.to_snake_case())
	if object.get_meta_list().all(func(a: StringName): return not a.begins_with(META_PREFIX)):
		all_objects.erase(object)


static func select(object: Object) -> void:
	left_object = object


static func select_left(object: Object) -> void:
	select(object)


static func select_right(object: Object) -> void:
	right_object = object


static func _init_log_file() -> void:
	const DIR := "user://logs"
	const FILE_PATH_BASE := DIR + "/log%d.txt"
	
	var log_count := DirAccess.get_files_at(DIR).size()
	
	if log_count >= max_log_count:
		for i in (max_log_count - 1):
			var old_file := FileAccess.open(FILE_PATH_BASE % (i + 1), FileAccess.READ)
			var new_file := FileAccess.open(FILE_PATH_BASE % i, FileAccess.WRITE)
			
			new_file.store_string(old_file.get_as_text())
		
		_log_file_idx = log_count - 1
	else:
		_log_file_idx = log_count


static func get_log_path() -> String:
	return LOG_FILE_PATH_BASE % _log_file_idx


static func _flush_log_file() -> void:
	if not FileAccess.file_exists(get_log_path()):
		FileAccess.open(get_log_path(), FileAccess.WRITE)
	
	var file := FileAccess.open(get_log_path(), FileAccess.READ_WRITE)
	file.seek_end()
	file.store_line(_log_queue)
	file.close()


func update() -> void:
	if not is_instance_valid(left_object):
		left_object = get_tree().current_scene
	if not is_instance_valid(right_object):
		right_object = null
	
	if is_left_label_bound():
		debug_label_left.text = Debug.get_text(left_object)
	if is_right_label_bound():
		debug_label_right.text = Debug.get_text(right_object)
	
	var invalid_objects := PackedInt32Array()
	var debug_file := FileAccess.open(DEBUG_FILE_PATH, FileAccess.WRITE)
	for i in all_objects.size():
		var object := all_objects[i]
		if is_instance_valid(object):
			debug_file.store_string(Debug.get_text(object, false) + "\n\n")
		else:
			invalid_objects.append(i - invalid_objects.size())
	
	for i in invalid_objects:
		all_objects.remove_at(i)


func is_left_label_bound() -> bool:
	return is_instance_valid(debug_label_left)


func is_right_label_bound() -> bool:
	return is_instance_valid(debug_label_right)


func is_left_bound() -> bool:
	return is_instance_valid(left_object)


func is_right_bound() -> bool:
	return is_instance_valid(right_object)


func _handle_toggle() -> void:
	if Input.is_action_just_pressed("command_line_toggle"):
		if command_line.visible:
			command_line.hide()
			get_tree().paused = false
		else:
			command_line.show()
			command_line.grab_focus()
			command_line.clear()
			
			get_tree().paused = true
	
	if Input.is_action_just_pressed("debug_overlay_toggle"):
		debug_label_left.visible = not debug_label_left.visible
		debug_label_right.visible = not debug_label_right.visible
