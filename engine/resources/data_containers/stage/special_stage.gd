@tool
@abstract
extends StageBase
class_name SpecialStage

## A stage that gives the player rewards in return for coins.

# ==============================================================================
@export var file: SpecialStageTemplate
# ==============================================================================
var _bg: Texture2D = null : get = get_bg
# ==============================================================================

func _is_special() -> bool:
	return true


func _get_name_id() -> String:
	return file.name if file else "stage.special." + name.to_snake_case().replace("_", "-")


func _get_description_id() -> String:
	return get_name_id().to_snake_case().replace("_", "-") + ".description"


func _get_info() -> Array:
	if completed:
		return [
			5,
			Color("10df80"),
			"stage-select.details.property.complete"
		]
	
	return [
		11,
		Color("ffd700"),
		"stage-select.details.property.special"
	]


func get_bg() -> Texture2D:
	if not _bg:
		_bg = _get_bg()
	return _bg
