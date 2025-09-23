extends Resource
class_name StageMod

# ==============================================================================
@export var data: StageModData :
	get:
		if not data:
			data = ResourceLoader.load(get_script().resource_path.get_basename() + ".tres")
		return data

var icon: TextureRect :
	get:
		if not is_instance_valid(icon):
			icon = TextureRect.new()
			icon.texture = AtlasTexture.new()
			icon.texture.atlas = data.atlas
			icon.texture.region = data.atlas_region
		
		return icon
# ==============================================================================

func get_tree() -> SceneTree:
	return icon.get_tree()


static func from_path(path: String) -> StageMod:
	if path.is_relative_path():
		path = "res://assets/mods/".path_join(path)
	
	return ResourceLoader.load(path.get_basename() + ".gd").new()


func _export() -> String:
	return get_path()


static func _import(path: String) -> StageMod:
	return from_path(path)
