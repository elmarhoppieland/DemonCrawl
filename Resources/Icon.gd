@tool
extends AtlasTexture
class_name Icon

# ==============================================================================
@export var name := "" :
	set(value):
		name = value
		
		var data := Icon.get_icon_data(name)
		if data:
			atlas = data.get_atlas()
			region = data.get_region()
		else:
			atlas = null
			region = Rect2()
# ==============================================================================

func _validate_property(property: Dictionary) -> void:
	if property.name in [&"atlas", &"region"]:
		property.usage |= PROPERTY_USAGE_READ_ONLY


## Returns data about the icon with the given name. If the icon [b]source[/b] does not exist, returns [code]null[/code].
## To check if an icon exists, use [method has_icon].
static func get_icon_data(icon_name: String) -> IconData:
	var data := IconData.new(icon_name)
	match icon_name.get_base_dir():
		"":
			data.source_dict = AssetManager.ICONS
			data.source_atlas = preload("res://Assets/sprites/icons.png")
		"mastery", "mastery3":
			data.source_dict = AssetManager.MASTERIES
			data.source_atlas = preload("res://Assets/sprites/Masteries.png")
		"mastery0":
			data.source_dict = AssetManager.MASTERIES
			data.source_atlas = preload("res://Assets/sprites/Masteries0.png")
		"mastery1":
			data.source_dict = AssetManager.MASTERIES
			data.source_atlas = preload("res://Assets/sprites/Masteries1.png")
		"mastery2":
			data.source_dict = AssetManager.MASTERIES
			data.source_atlas = preload("res://Assets/sprites/Masteries2.png")
		"chest":
			data.source_dict = AssetManager.CHESTS
			data.source_atlas = preload("res://Assets/sprites/chests.png")
		_:
			return null
	
	return data


## Returns whether an icon with the given [code]name[/code] exists.
static func has_icon(icon_name: String) -> bool:
	var data := get_icon_data(icon_name)
	if not data:
		return false
	return icon_name.get_file() in data.source_dict


class IconData:
	var source_dict: Dictionary
	var source_atlas: Texture2D
	var name: String
	
	
	func _init(_name: String) -> void:
		name = _name
	
	func get_atlas() -> Texture2D:
		var override = EffectManager.propagate_value("parse_icon_atlas", null, [name])
		if override != null:
			return override
		
		return source_atlas
	
	func get_region() -> Rect2i:
		var override = EffectManager.propagate_value("parse_icon_rect", Rect2i(), [name])
		if override != Rect2i():
			return override
		
		if name.get_file() in source_dict:
			return source_dict[name.get_file()]
		if "*" in source_dict:
			return source_dict["*"]
		return Rect2i()
