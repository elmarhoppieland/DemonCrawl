@tool
extends Stage
class_name SpecialStage

## A stage that gives the player rewards in return for coins.

# ==============================================================================
var _bg: Texture2D = null : get = get_bg
var _icon: Texture2D = null : get = get_icon
var _icon_small: Texture2D = null : get = get_icon_small

var _dest_scene: PackedScene = null : get = get_dest_scene
# ==============================================================================

func create_big_icon() -> ImageTexture:
	if get_icon():
		return get_icon()
	
	var image: Image
	image = get_bg().get_image()
	
	image = image.get_region(Rect2i(image.get_width() / 2 - image.get_height() / 2, 0, image.get_height(), image.get_height()))
	image.resize(58, 58)
	
	return ImageTexture.create_from_image(image)


func _get_theme() -> Theme:
	return null


func get_bg() -> Texture2D:
	if not _bg:
		_bg = _get_bg()
	return _bg


func _get_bg() -> Texture2D:
	return null


func get_icon() -> Texture2D:
	if not _icon:
		_icon = _get_icon()
	return _icon


func _get_icon() -> Texture2D:
	return null


func get_icon_small() -> Texture2D:
	if not _icon_small:
		_icon_small = _get_icon_small()
	return _icon_small


func _get_icon_small() -> Texture2D:
	return null


func get_dest_scene() -> PackedScene:
	if not _dest_scene:
		_dest_scene = _get_dest_scene()
	return _dest_scene


func _get_dest_scene() -> PackedScene:
	return null
