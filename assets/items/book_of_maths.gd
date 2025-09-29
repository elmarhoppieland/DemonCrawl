@tool
extends OmenItem

# ==============================================================================
const ZERO_RANGE := 5
const MEAN := 0.0
const DEVIATION := 1.0
# ==============================================================================

func _enable() -> void:
	get_quest().get_tooltip_context().process_text.connect(_process_text)


func _disable() -> void:
	get_quest().get_tooltip_context().process_text.disconnect(_process_text)


func _process_text(text: String) -> String:
	var i := 0
	var in_tag := false
	var num_string := ""
	while i < text.length():
		var c := text[i]
		if c == "[":
			in_tag = true
			i += 1
			continue
		if c == "]":
			in_tag = false
			i += 1
			continue
		
		if in_tag:
			i += 1
			continue
		
		if c.is_valid_int():
			num_string += c
			i += 1
			continue
		
		if num_string.is_empty():
			i += 1
			continue
		
		var start_idx := i - num_string.length()
		var num := convert_to_random(num_string.to_int())
		var new_num_string := str(num)
		text = text\
			.erase(start_idx, num_string.length())\
			.insert(start_idx, new_num_string)
		i = start_idx + new_num_string.length()
		num_string = ""
	
	return text


func convert_to_random(n: int) -> int:
	if n == 0:
		return randi_range(-ZERO_RANGE, ZERO_RANGE)
	
	return roundi(n * exp(randfn(MEAN, DEVIATION)))
