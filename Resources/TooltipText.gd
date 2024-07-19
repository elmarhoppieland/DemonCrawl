extends RefCounted
class_name TooltipText

# ==============================================================================
const _SUBTEXT_COLOR := Color("a9a9a9")
# ==============================================================================
var _text := ""
var _color := Color.WHITE
var _translate := true

var _transforms: Array[Callable] = []

var _previous_line: TooltipText
# ==============================================================================

func _init(text: String = "") -> void:
	_text = text


func set_text(text: String) -> TooltipText:
	_text = text
	return self


func set_color(color: Color) -> TooltipText:
	_color = color
	return self


func set_translate(translate: bool = true) -> TooltipText:
	_translate = translate
	return self


func as_subtext() -> TooltipText:
	return set_color(_SUBTEXT_COLOR)


func to_upper() -> TooltipText:
	return add_transform(func(string: String) -> String: return string.to_upper())


func to_lower() -> TooltipText:
	return add_transform(func(string: String) -> String: return string.to_lower())


func capitalize() -> TooltipText:
	return add_transform(func(string: String) -> String: return string.capitalize())


func c_escape() -> TooltipText:
	return add_transform(func(string: String) -> String: return string.c_escape())


func c_unescape() -> TooltipText:
	return add_transform(func(string: String) -> String: return string.c_unescape())


func dedent() -> TooltipText:
	return add_transform(func(string: String) -> String: return string.dedent())


func format(values: Variant, placeholder: String = "{_}") -> TooltipText:
	return add_transform(func(string: String) -> String: return string.format(values, placeholder))


func indent(prefix: String) -> TooltipText:
	return add_transform(func(string: String) -> String: return string.indent(prefix))


func add_transform(transform: Callable) -> TooltipText:
	_transforms.append(transform)
	return self


func add_line(text: String) -> TooltipText:
	var next_line := TooltipText.new(text)
	next_line._previous_line = self
	return next_line


func _to_string() -> String:
	var text := ""
	
	if _previous_line:
		text = str(_previous_line) + "\n"
	
	var this_text := tr(_text) if _translate else _text
	for transform in _transforms:
		this_text = transform.call(this_text)
	
	text += "[color=#%s]%s[/color]" % [_color.to_html(), this_text]
	
	return text
