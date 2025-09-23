@tool
extends TokenShopReward
class_name TokenShopEternalIncrementReward

# ==============================================================================
@export var script_name := "" :
	set(value):
		script_name = value
		notify_property_list_changed()
@export var property := ""
# ==============================================================================

@warning_ignore("shadowed_variable")
func _validate_property(property: Dictionary) -> void:
	match property.name:
		&"property":
			if not script_name.is_empty():
				property.hint = PROPERTY_HINT_ENUM_SUGGESTION
				var eternals := PackedStringArray()
				var eternal_list := Eternity.get_defaults_cfg().get_eternals(script_name)
				for prop in UserClassDB.class_get_script(script_name).get_property_list():
					if prop.type == TYPE_INT and prop.name in eternal_list:
						eternals.append(prop.name)
				property.hint_string = ",".join(eternals)
		&"script_name":
			property.hint = PROPERTY_HINT_ENUM_SUGGESTION
			property.hint_string = ",".join(Eternity.get_defaults_cfg().get_scripts())


func _apply() -> void:
	var script := UserClassDB.class_get_script(script_name)
	script.set(property, script.get(property) + 1)


func _reapply() -> void:
	_apply()
