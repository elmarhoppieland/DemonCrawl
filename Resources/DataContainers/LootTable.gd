@tool
extends Resource
class_name LootTable

# ==============================================================================
@export var type := TYPE_BOOL :
	set(value):
		type = value
		notify_property_list_changed()
@export var items_class := "Object" :
	set(value):
		items_class = value
		notify_property_list_changed()
@export var auto_sort := true
# ==============================================================================
var items: Array[Dictionary] = []
# ==============================================================================

func _init() -> void:
	if auto_sort and not Engine.is_editor_hint():
		items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return a.weight > b.weight
		)


func generate(modifier: float = 1.0) -> Variant:
	var cumulative := PackedFloat32Array([items[0].weight])
	
	for i in range(1, items.size()):
		cumulative.append(cumulative[-1] + items[i].weight * (modifier ** i))
	
	var random := randf_range(0, cumulative[-1])
	var idx := cumulative.bsearch(random)
	match type:
		TYPE_NIL:
			return UserClassDB.class_get_script(items[idx].value)
		_:
			return items[idx].value


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"type":
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = "Class," + ",".join(range(1, TYPE_MAX).map(func(t: Variant.Type) -> String: return type_string(t)))
		"items_class":
			if type != TYPE_OBJECT:
				property.usage &= ~PROPERTY_USAGE_EDITOR
			property.hint = PROPERTY_HINT_TYPE_STRING
			property.hint_string = "Object"


func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	
	properties.append({
		"name": "item_count",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_ARRAY | PROPERTY_USAGE_DEFAULT,
		"class_name": "Items,item_",
	})
	
	for i in items.size():
		if type == TYPE_OBJECT:
			properties.append({
				"name": "item_%d/value" % i,
				"type": TYPE_OBJECT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": items_class
			})
		elif type == TYPE_NIL:
			properties.append({
				"name": "item_%d/value" % i,
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_TYPE_STRING,
				"hint_string": "Object"
			})
		else:
			properties.append({
				"name": "item_%d/value" % i,
				"type": type
			})
		
		properties.append({
			"name": "item_%d/weight" % i,
			"type": TYPE_FLOAT
		})
	
	return properties


func _get(property: StringName) -> Variant:
	if property == "item_count":
		return items.size()
	
	if property.match("item_*/*"):
		return items[property.get_base_dir().to_int()][property.get_file()]
	
	if property.match("item_*"):
		return items[property.get_base_dir().to_int()]
	
	return null


func _set(property: StringName, value: Variant) -> bool:
	if property == "item_count":
		while items.size() < value:
			items.append({
				"value": null,
				"weight": 0.0
			})
		if items.size() > value:
			items.resize(value)
		notify_property_list_changed()
		return true
	
	if property.match("item_*/*"):
		items[property.get_base_dir().to_int()][property.get_file()] = value
		notify_property_list_changed()
		return true
	
	if property.match("item_*"):
		items[property.get_base_dir().to_int()] = value
		notify_property_list_changed()
		return true
	
	return false


func _property_can_revert(property: StringName) -> bool:
	return property.match("item_*/*")


func _property_get_revert(property: StringName) -> Variant:
	if not property.match("item_*/*"):
		return null
	
	if property.get_file() == "weight":
		return 0.0
	
	if property.get_file() == "value":
		match type:
			TYPE_NIL:
				return "Object"
			TYPE_STRING, TYPE_STRING_NAME:
				return ""
			_:
				return null
	
	return null
