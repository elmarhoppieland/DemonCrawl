@tool
extends StaticClass
class_name IconManager

## A manager for icons.

# ==============================================================================
static var _icon_cache: Dictionary[String, IconData] = {}
# ==============================================================================

## Returns an [IconManager.IconData] object for the icon with the given [code]name[/code].
## [br][br]If the icon was found, it is cached and later calls with this name will
## return this same object.
## [br][br]If the icon was not found, an empty [IconManager.IconData] object is returned.
## This object is safe to call methods like [code]create_texture()[/code] on.
## These methods will return either [code]null[/code] or another default value
## if the icon does not exist.
static func get_icon_data(name: String) -> IconData:
	if name in _icon_cache and not Engine.is_editor_hint():
		return _icon_cache[name]
	
	var json := _get_icons_data()
	if json.is_empty():
		return IconData.new()
	
	if name.get_base_dir() not in json:
		push_error("No icon with name '%s' exists: Atlas not found." % name)
		return IconData.new()
	
	var atlas_data := json[name.get_base_dir()] as Dictionary
	
	var data := IconData.new()
	
	for icon in atlas_data.icons:
		if icon.name == name.get_file():
			data._atlas = load(atlas_data.atlas)
			data._region = Rect2(
				icon.x, icon.y, icon.w, icon.h
			)
			return data
	
	push_error("Icon '%s' not found under base '%s'." % [name.get_file(), name.get_base_dir()])
	return data


## Overrides the icon with the given [code]name[/code] to another [code]atlas[/code].
## [br][br][method get_icon_data] will now return an [IconManager.IconData] object for the given
## atlas instead of whatever it would otherwise return.
## [br][br]If no icon with the given [code]name[/code] exists, this method will
## still create an override and will therefore create a new icon.
## [br][br]If [code]atlas[/code] is [code]null[/code], the atlas will not be overridden,
## and only the atlas region will change.
## [br][br]This method is mostly intended for modding purposes.
static func override_icon(name: String, atlas: Texture2D, region: Rect2 = Rect2()) -> IconData:
	var data := IconData.new()
	data._atlas = atlas if atlas else get_icon_data(name).get_atlas()
	data._region = region
	_icon_cache[name] = data
	return data


## Returns whether an icon with the given [code]name[/code] exists or not.
## [br][br][b]Note:[/b] [method get_icon_data] never returns [code]null[/code],
## so even if the icon does not exist, it is still safe to call methods on the return
## value of [method get_icon_data].
static func icon_exists(name: String) -> bool:
	if name in _icon_cache and not Engine.is_editor_hint():
		return true
	
	var json := _get_icons_data()
	if json.is_empty():
		return false
	
	if name.get_base_dir() not in json:
		return false
	
	for icon in json[name.get_base_dir()].icons:
		if icon.name == name.get_file():
			return true
	
	return false


static func _open_data_file(flags: FileAccess.ModeFlags = FileAccess.READ) -> FileAccess:
	var file := FileAccess.open(__IconManagerPlugin.ICONS_FILE, flags)
	if not file:
		push_error("Could not open file '%s': %s." % [__IconManagerPlugin.ICONS_FILE, error_string(FileAccess.get_open_error())])
	if file.get_length() == 0:
		return null
	return file


static func _get_icons_data() -> Dictionary:
	var file := _open_data_file()
	if not file:
		return {}
	
	var json = JSON.parse_string(file.get_as_text())
	if not json or not json is Dictionary:
		push_error("Could not parse JSON at path '%s' as a Dictionary." % __IconManagerPlugin.ICONS_FILE)
		return {}
	
	return json


## A data container class for icons stored in the [IconManager].
class IconData:
	var _atlas: Texture2D : get = get_atlas
	var _region := Rect2() : get = get_region
	
	## Creates and returns a new [Texture2D] resource for this icon.
	## [br][br]If the icon does not exist, this method returns [code]null[/code].
	func create_texture() -> Texture2D:
		if is_empty():
			return null
		
		if get_region() == Rect2():
			return get_atlas().duplicate()
		
		var atlas_texture := AtlasTexture.new()
		atlas_texture.atlas = get_atlas()
		atlas_texture.region = get_region()
		return atlas_texture
	
	## Overrides the atlas of this icon. This method is mostly intended for modding purposes.
	func override_atlas(new_atlas: Texture2D) -> IconData:
		if new_atlas:
			_atlas = new_atlas
		return self
	
	## Overrides the atlas region of this icon. This method is mostly intended for modding purposes.
	func override_region(new_region: Rect2) -> IconData:
		if new_region != Rect2():
			_region = new_region
		return self
	
	## Returns the atlas this icon is in.
	func get_atlas() -> Texture2D:
		return _atlas
	
	## Returns the atlas region that is used by this icon.
	func get_region() -> Rect2:
		return _region
	
	## Returns whether this is an empty [IconManager.IconData] object, i.e. whether this icon exists.
	func is_empty() -> bool:
		return get_atlas() == null
