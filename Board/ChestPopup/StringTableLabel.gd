@tool
extends Label
class_name StringTableLabel

# ==============================================================================
@export var table_name := &"" :
	set(value):
		table_name = value
		
		table = StringTable.open(table_name)
		
		if Engine.is_editor_hint():
			if table_name.is_empty():
				text = ""
			else:
				text = table.get_strings()[0]
# ==============================================================================
var table: StringTable
# ==============================================================================

func generate() -> void:
	text = table.get_strings()[RNG.randi() % table.get_strings().size()]


func _validate_property(property: Dictionary) -> void:
	if not Engine.is_editor_hint():
		return
	
	if property.name == "text":
		property.usage ^= PROPERTY_USAGE_EDITOR
	if property.name == "table_name":
		property.hint = PROPERTY_HINT_ENUM_SUGGESTION
		property.hint_string = &",".join(Array(DirAccess.get_files_at("res://Assets/string_tables/")).map(func(a: String): return a.get_basename()))
