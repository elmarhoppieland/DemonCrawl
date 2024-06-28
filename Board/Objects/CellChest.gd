extends CellObject
class_name CellChest

# ==============================================================================
var texture: Icon

var tween: Tween
# ==============================================================================

func get_texture() -> Icon:
	if not texture:
		texture = AssetManager.get_icon("chest/default").duplicate()
	return texture


func interact() -> void:
	if tween:
		return
	
	const CHEST_OPEN_ANIM_DURATION := 0.2
	const CHEST_OPEN_WAIT_DURATION := 0.5
	
	const CHEST_ATLAS_WIDTH := 5
	const CHEST_ATLAS_MAX_X := (CHEST_ATLAS_WIDTH - 1) * Board.CELL_SIZE.x
	
	tween = cell.create_tween()
	
	tween.tween_method(func(value: float):
		texture.region.position.x = floorf(value / Board.CELL_SIZE.x) * Board.CELL_SIZE.x
	, 0.0, CHEST_ATLAS_MAX_X, CHEST_OPEN_ANIM_DURATION)
	
	tween.tween_interval(CHEST_OPEN_WAIT_DURATION)
	tween.tween_callback(ChestPopup.show_rewards)
	tween.tween_callback(clear)


func get_charitable_amount() -> int:
	return 5
