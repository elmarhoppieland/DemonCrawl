@abstract
extends Object
class_name Debug

## Singleton for debugging purposes.

# ==============================================================================
static var max_log_count: int = Eternal.create(100, "settings") ## The maximum number of log files this singleton is allowed to create.
static var verbose_logging: bool = Eternal.create(false, "settings") ## If [code]true[/code], this singleton will print vebose events (see [method log_event_verbose]) in addition to non-verbose events.

static var _log_file: FileAccess :
	get:
		if not _log_file:
			const DIR := "user://logs"
			const FILE_PATH_BASE := DIR + "/log%d.txt"
			
			var log_count := DirAccess.get_files_at(DIR).size()
			
			var log_file_index: int
			if log_count >= max_log_count:
				for i in (max_log_count - 1):
					DirAccess.rename_absolute(FILE_PATH_BASE % (i + 1), FILE_PATH_BASE % i)
				
				log_file_index = log_count - 1
			else:
				log_file_index = log_count
			
			_log_file = FileAccess.open(FILE_PATH_BASE % log_file_index, FileAccess.WRITE)
			if not _log_file:
				log_error("Could not open log file at path '%s': %s." % [FILE_PATH_BASE % log_file_index, error_string(FileAccess.get_open_error())])
		
		return _log_file
# ==============================================================================

static func flush_log_file() -> void:
	_log_file.flush()


## Logs [param message], adding a new line in the log file, and if
## [param print_to_console] is [code]true[/code] and this is a debug build,
## prints to the console.
static func log_event(message: String, color: Color = Color.AQUA, print_to_console: bool = true, show_toast: bool = true) -> void:
	if OS.is_debug_build() and print_to_console:
		print_rich("[color=#%s]%s[/color]" % [color.to_html(), message])
	
	_log_file.store_line("[%s] %s" % [Time.get_datetime_string_from_system().replace("T", " @ "), message])
	
	if show_toast:
		Toasts.add_debug_toast(message)


## Logs [param message], if [member verbose_logging] is [code]true[/code].
## See [method log_event].
static func log_event_verbose(message: String, color: Color = Color.AQUA, print_to_console: bool = true, show_toast: bool = true) -> void:
	if verbose_logging:
		log_event(message, color, print_to_console, show_toast)


## Logs an event, together with the method that initially called [Debug].
static func log_stack_event(message: String, color: Color = Color.WHITE, prefix: String = "", print_to_console: bool = true, show_toast: bool = true) -> void:
	if not prefix.is_empty():
		prefix += ": "
	
	var stack := get_stack()
	while not stack.is_empty() and stack[0].source == (Debug as Script).resource_path:
		stack.pop_front()
	
	if stack.is_empty():
		log_event(message, color, print_to_console, show_toast)
		return
	
	if OS.is_debug_build() and print_to_console:
		print_rich("[color=#%s]● %s:%d @ %s() - %s[/color]" % [color.to_html(), stack[0].source, stack[0].line, stack[0].function, message])
	
	log_event("%s%s:%d @ %s() - %s" % [
		Time.get_datetime_string_from_system().replace("T", " @ "),
		prefix,
		stack[0].source,
		stack[0].line,
		stack[0].function,
		message
	], Color.WHITE, false, false)
	
	if show_toast:
		Toasts.add_debug_toast(prefix + message)


## Logs [param error], and prints an error message.
static func log_error(error: String) -> void:
	log_stack_event(error, Color("ff786b"), "ERROR")
	push_error(error)


## Logs [param warning], and prints a warning message.
static func log_warning(warning: String) -> void:
	log_stack_event(warning, Color("ffde66"), "WARNING")
	push_warning(warning)


## Logs information about the given [param value]. The information that is logged
## is the following:
## - For non-[Object] types, the value itself is logged (converted to a string),
## and its type.
## - For [Object] types, this method logs the value's class, the value's properties
## and their values, and the value's script identifier, if it has a script.
static func log_info(value: Variant) -> void:
	var info := str(value) + "\n" + type_string(typeof(value))
	if value is Object:
		info += "\n" + value.get_class()\
			+ "".join(value.get_property_list().map(func(prop: Dictionary) -> String: return "\n%s: %s" % [prop.name, value.get(prop.name)] if prop.name in value else ""))
		if value.get_script() != null:
			info += "\n" + UserClassDB.script_get_identifier(value.get_script())
	log_event(info)
