@tool
extends QuestGenerationSequenceBase
class_name QuestGenerationStageSequence

# ==============================================================================
var length_distribution: Array[LengthWeight] = []
# ==============================================================================

func _generate(stage_list: Array[StageTemplateBase]) -> Array[StageTemplateBase]:
	var length := get_length()
	return stage_list.slice(0, length)


func get_length() -> int:
	if length_distribution.is_empty():
		return 0
	
	var cumulative := PackedFloat32Array([length_distribution[0].weight])
	
	for i in range(1, length_distribution.size()):
		cumulative.append(cumulative[-1] + length_distribution[i].weight)
	
	var random := randf_range(0, cumulative[-1])
	var idx := cumulative.bsearch(random)
	return length_distribution[idx].length


func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary] = []
	
	props.append({
		"name": "length_distribution_count",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_ARRAY | PROPERTY_USAGE_DEFAULT,
		"class_name": "Length Distribution,length_distribution_"
	})
	
	for i in length_distribution.size():
		for prop in length_distribution[i].get_property_list():
			if prop.name == "script":
				continue
			if prop.type == TYPE_NIL:
				continue
			prop.name = ("length_distribution_%d" % i).path_join(prop.name)
			props.append(prop)
	
	return props


func _get(property: StringName) -> Variant:
	if property == "length_distribution_count":
		return length_distribution.size()
	
	if property.match("length_distribution_*/*"):
		var index := property.get_base_dir().to_int()
		var property_key := property.get_file()
		return length_distribution[index][property_key]
	
	if property.match("length_distribution_*"):
		var index := property.get_base_dir().to_int()
		return length_distribution[index]
	
	return null


func _set(property: StringName, value: Variant) -> bool:
	if property == "length_distribution_count":
		while length_distribution.size() < value:
			var length_weight := LengthWeight.new()
			if length_distribution.is_empty():
				length_weight.length = 1
			else:
				length_weight.length = length_distribution[-1].length + 1
			length_distribution.append(length_weight)
		if length_distribution.size() > value:
			length_distribution.resize(value)
		notify_property_list_changed()
		return true
	
	if property.match("length_distribution_*/*"):
		var index := property.get_base_dir().to_int()
		var property_key := property.get_file()
		length_distribution[index][property_key] = value
		return true
	
	#if property.match("item_*"):
		#items[property.get_base_dir().to_int()] = value
		#notify_property_list_changed()
		#return true
	
	return false


class LengthWeight:
	@export var length := 0
	@export_range(0.0, 1.0) var weight := 0.0
