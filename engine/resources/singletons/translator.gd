@tool
extends Object
class_name Translator

# ==============================================================================
static var locale: String = Eternal.create("en", "settings") :
	set(value):
		locale = value
		TranslationServer.set_locale(value)
# ==============================================================================

static func translate(message: StringName, n: int = 1, context: StringName = &"") -> String:
	var translated := String(TranslationServer.translate(message, context))
	
	var i := _find_unescaped(translated, "<")
	while i != -1:
		var plurality := translated.substr(i, _find_unescaped(translated, ">", i + 1) - i + 1)
		translated = translated.replace(plurality, _parse_plurality(plurality, n))
		i = _find_unescaped(translated, "<", i + 1)
	
	return translated


static func translate_plural(message: StringName, plural_message: StringName, n: int = 1, context: StringName = &"") -> String:
	if n == 1:
		return translate(message, n, context)
	return translate(plural_message, n, context)


static func _parse_plurality(plurality: String, n: int) -> String:
	plurality = plurality.trim_prefix("<").trim_suffix(">")
	
	for part in plurality.split("|"):
		if ":" not in part:
			return part
		
		var conditions := part.get_slice(":", 0)
		if _matches_conditions(conditions.split(","), n):
			return part.trim_prefix(conditions + ":")
	
	return ""


static func _matches_conditions(conditions: PackedStringArray, n: int) -> bool:
	for condition in conditions:
		if condition.ends_with("+"):
			if n >= condition.to_int():
				return true
		elif condition.ends_with("-"):
			if n <= condition.to_int():
				return true
		elif condition.to_int() == n:
			return true
	
	return false


static func _find_unescaped(string: String, what: String, from: int = 0, escape_char: String = "\\") -> int:
	var i := string.find(what, from)
	while i != -1:
		var escapes := 0
		for j in range(i - 1, -1, -1):
			if string[j] != escape_char:
				break
			escapes += 1
		
		if escapes % 2 == 0:
			return i
		
		i = string.find(what, i + 1)
	
	return -1
