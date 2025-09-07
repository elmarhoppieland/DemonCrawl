@tool
extends Resource
class_name MasteryData

# ==============================================================================
@export var name := "" :
	set(value):
		var old := name
		name = value
		
		for i in description.size():
			if description[i].is_empty() or description[i] == _name_to_description(old, i + 1):
				description[i] = _name_to_description(value, i + 1)
		for i in unlock_text.size():
			if unlock_text[i].is_empty() or unlock_text[i] == _name_to_unlock_text(old, i + 1):
				unlock_text[i] = _name_to_unlock_text(value, i + 1)
		
		emit_changed()
@export var description: Array[String] = ["", "", ""]
@export var unlock_text: Array[String] = ["", "", ""]
@export var icon: Array[Texture2D] = [null, null, null]
@export var cost: Array[int] = [10, 20, 30]
@export var ability_charges := 0
@export var mastery_script: Script = null
# ==============================================================================

func _property_can_revert(property: StringName) -> bool:
	return property in [&"description", &"unlock_text", &"name", &"mastery_script"]


func _property_get_revert(property: StringName) -> Variant:
	if property == &"description":
		if name.is_empty():
			return ["", "", ""] as Array[String]
		var value: Array[String] = []
		for i in 3:
			value.append(_name_to_description(name, i + 1))
		return value
	if property == &"unlock_text":
		if name.is_empty():
			return ["", "", ""] as Array[String]
		var value: Array[String] = []
		for i in 3:
			value.append(_name_to_unlock_text(name, i + 1))
		return value
	if property == &"name":
		return "mastery." + resource_path.get_file().get_basename().to_snake_case().replace("_", "-")
	if property == &"mastery_script":
		if mastery_script:
			return null
		
		var path := resource_path.get_basename() + ".gd"
		if ResourceLoader.exists(path):
			return load(path)
	
	return null


## Creates a new [Mastery] for this [MasteryData].
func create(level: int = 0, charges: int = 0) -> Mastery:
	return mastery_script.new(instantiate(level, charges))


## Creates a [MasteryInstanceData] for this [MasteryData]
func instantiate(level: int = 0, charges: int = 0) -> MasteryInstanceData:
	return MasteryInstanceData.new(self, level, charges)


@warning_ignore("shadowed_variable")
func _name_to_description(name: String, level: int) -> String:
	return name.to_snake_case().replace("_", "-") + ".description." + str(level)


@warning_ignore("shadowed_variable")
func _name_to_unlock_text(name: String, level: int) -> String:
	return name.to_snake_case().replace("_", "-") + ".unlock." + str(level)


func get_max_level() -> int:
	return description.size()
