@tool
extends Stage
class_name SpecialStage

## A stage that gives the player rewards in return for coins.

# ==============================================================================
@export var base: SpecialStageBase
# ==============================================================================
var _bg: Texture2D = null : get = get_bg

var _dest_scene: PackedScene = null : get = get_dest_scene
# ==============================================================================

func _get_theme() -> Theme:
	return null


func _get_name_id() -> String:
	return base.name if base else "stage.special." + name.to_snake_case().replace("_", "-")


func _get_description_id() -> String:
	return "stage.special." + name.to_snake_case().replace("_", "-") + ".description"


func _get_info() -> Array:
	if completed:
		return super()
	
	return [
		11,
		Color("ffd700"),
		"stage-select.details.property.special"
	]


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
