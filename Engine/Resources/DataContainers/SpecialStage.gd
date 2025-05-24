@tool
extends Stage
class_name SpecialStage

## A stage that gives the player rewards in return for coins.

# ==============================================================================
var _bg: Texture2D = null : get = get_bg

var _dest_scene: PackedScene = null : get = get_dest_scene
# ==============================================================================

func _get_theme() -> Theme:
	return null


func get_bg() -> Texture2D:
	if not _bg:
		_bg = _get_bg()
	return _bg


func _get_bg() -> Texture2D:
	return null


func get_dest_scene() -> PackedScene:
	if not _dest_scene:
		_dest_scene = _get_dest_scene()
	return _dest_scene


func _get_dest_scene() -> PackedScene:
	return null
