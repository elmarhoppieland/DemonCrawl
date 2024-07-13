@tool
extends Resource
class_name ItemData

# ==============================================================================
const TYPE_COLORS := {
	Item.Type.PASSIVE: Color("00000000"),
	Item.Type.CONSUMABLE: Color("14a46480"),
	Item.Type.MAGIC: Color("2a6eb080"),
	Item.Type.OMEN: Color("bc383880"),
	Item.Type.LEGENDARY: Color("b3871a80")
}
# ==============================================================================
@export var name := "ITEM_" + resource_path.get_file().get_basename().to_snake_case().to_upper() :
	set(value):
		if description.is_empty() or description == name.to_snake_case().to_upper() + "_DESCRIPTION":
			if value.is_empty():
				description = ""
			else:
				description = value.to_snake_case().to_upper() + "_DESCRIPTION"
		name = value
@export_multiline var description := ""
@export var type := Item.Type.PASSIVE
@export var mana := 0
@export var cost := 0
@export var atlas_region := Rect2(0, 0, 16, 16)
@export var atlas: Texture2D = preload("res://Assets/sprites/items.png")
# ==============================================================================
var _small_icon: Texture2D
# ==============================================================================

func get_color() -> Color:
	return TYPE_COLORS[type]


func get_item_script() -> Script:
	return ResourceLoader.load(resource_path.get_slice(".", 0) + ".gd")


func get_small_icon() -> Texture2D:
	if _small_icon:
		return _small_icon
	
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = atlas
	atlas_texture.region = atlas_region
	
	var image := atlas_texture.get_image()
	image.resize(8, 8, Image.INTERPOLATE_NEAREST)
	
	_small_icon = ImageTexture.create_from_image(image)
	return _small_icon


static func from_path(path: String) -> ItemData:
	if path.is_relative_path():
		path = "res://Assets/items/".path_join(path)
	
	return ResourceLoader.load(path.get_basename() + ".tres")


func _property_can_revert(property: StringName) -> bool:
	return property in get_script().get_script_property_list().map(func(prop: Dictionary): return prop.name)


func _property_get_revert(property: StringName) -> Variant:
	if property == &"description":
		if name.is_empty():
			return ""
		return name.to_snake_case().to_upper() + "_DESCRIPTION"
	if property == &"name":
		return "ITEM_" + resource_path.get_file().get_basename().to_snake_case().to_upper()
	if property == &"atlas":
		return preload("res://Assets/sprites/items.png")
	
	return get_script().get_property_default_value(property)
