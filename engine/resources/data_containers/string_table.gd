@tool
extends Resource
class_name StringTable

# ==============================================================================
static var _selected_locale := "en"
# ==============================================================================
var data := {}
# ==============================================================================

func _validate_property(property: Dictionary) -> void:
	if property.name == "data":
		property.usage |= PROPERTY_USAGE_STORAGE


func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = [{
		"name": "locale",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_LOCALE_ID,
		"usage": PROPERTY_USAGE_EDITOR
	}, {
		"name": "string_count",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_ARRAY,
		"class_name": "Strings,string_"
	}]
	
	for i in get_strings().size():
		property_list.append({
			"name": "string_" + str(i),
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_MULTILINE_TEXT,
			"usage": PROPERTY_USAGE_EDITOR
		})
	
	return property_list


func _set(property: StringName, value: Variant) -> bool:
	if property.match("string_*") and property != &"string_count":
		get_strings()[property.to_int()] = value
		return true
	
	match property:
		&"locale":
			_selected_locale = value
			if not _selected_locale in data:
				data[_selected_locale] = PackedStringArray()
		&"string_count":
			value = maxi(0, value)
			
			while get_strings().size() < value:
				get_strings().append("")
			
			if get_strings().size() > value:
				get_strings().resize(value)
			
			notify_property_list_changed()
		_:
			return false
	
	return true


func _get(property: StringName) -> Variant:
	if property.match("string_*") and property != &"string_count":
		return get_strings()[property.to_int()]
	
	match property:
		&"locale":
			return _selected_locale
		&"string_count":
			return get_strings().size()
		_:
			return null


func _property_can_revert(property: StringName) -> bool:
	if property.match("string_*") and property != &"string_count":
		return true
	return false


func _property_get_revert(property: StringName) -> Variant:
	if property.match("string_*"):
		return ""
	return null


func get_strings() -> PackedStringArray:
	if not _selected_locale in data:
		data[_selected_locale] = PackedStringArray()
	return data[_selected_locale]


static func open(name: String) -> StringTable:
	#if Effects.Signals:
		#var override: StringTable = Effects.get_string_table(null, name)
		#if override:
			#return override
	
	var path := "res://assets/string_tables/%s.tres" % name
	
	if not ResourceLoader.exists(path):
		return null
	
	return ResourceLoader.load(path)
