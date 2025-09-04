@tool
extends Resource
class_name MasteryInstanceData

# ==============================================================================
@export var data: MasteryData = null
@export var level := 0 :
	set(value):
		level = value
		emit_changed()
@export var charges := 0 :
	set(value):
		charges = value
		emit_changed()
# ==============================================================================

@warning_ignore("shadowed_variable")
func _init(data: MasteryData = null, level: int = 0, charges: int = 0) -> void:
	self.data = data
	self.level = level
	self.charges = charges


func _export_packed() -> Array:
	var array := [data]
	if level or charges:
		array.append(level)
	if charges:
		array.append(charges)
	return array


func create() -> Mastery:
	return data.create()


func get_name_text() -> String:
	var text := tr(data.name)
	if level > 0:
		text += " " + RomanNumeral.convert_to_roman(level)
	return text


func get_description_text(include_unlock_text: bool = false) -> String:
	if level < 1:
		return "(%s)" % tr(get_condition_text())
	
	var description := data.description.map(tr)
	if description.is_empty():
		return ""
	
	if level == description.size():
		description[-1] = ("[%d/%d] " % [charges, data.ability_charges]) + description[-1]
	else:
		description = description.slice(0, level)
	
	var text := "• " + "\n• ".join(description)
	if include_unlock_text:
		text += "\n\n(%s)" % tr(get_condition_text())
	return text


func get_condition_text() -> String:
	if level < 1:
		return ""
	return data.unlock_text[level - 1]


func get_icon() -> Texture2D:
	return data.icon[clampi(level - 1, 0, data.icon.size() - 1)]


func get_cost() -> int:
	if level < 1:
		return 0
	return data.cost[level - 1]


func get_max_level() -> int:
	return data.description.size()
