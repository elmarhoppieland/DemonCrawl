@tool
extends Label
class_name StringTableLabel

# ==============================================================================
@export var table: StringTable = null :
	set(value):
		table = value
		
		if Engine.is_editor_hint():
			if not table:
				text = ""
			else:
				text = table.get_strings()[0]
# ==============================================================================

func generate(format: Dictionary = {}) -> void:
	text = table.get_strings()[randi() % table.get_strings().size()].format(format)


func _validate_property(property: Dictionary) -> void:
	if property.name == "text":
		property.usage &= ~PROPERTY_USAGE_EDITOR & ~PROPERTY_USAGE_STORAGE
