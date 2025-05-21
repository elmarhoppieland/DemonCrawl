@tool
extends CellObject
class_name TreasureChest

# ==============================================================================
var tween: Tween
# ==============================================================================

func _get_texture() -> Icon:
	return IconManager.get_icon_data("chests/default").create_texture()


func _interact() -> void:
	if tween:
		return
	
	const CHEST_OPEN_ANIM_DURATION := 0.2
	const CHEST_OPEN_WAIT_DURATION := 0.5
	
	const CHEST_ATLAS_WIDTH := 5
	const CHEST_ATLAS_MAX_X := (CHEST_ATLAS_WIDTH - 1) * Cell.CELL_SIZE.x
	
	tween = get_cell().create_tween()
	
	tween.tween_method(func(value: float):
		get_texture().region.position.x = floorf(value / Cell.CELL_SIZE.x) * Cell.CELL_SIZE.x
	, 0.0, CHEST_ATLAS_MAX_X, CHEST_OPEN_ANIM_DURATION)
	
	tween.tween_interval(CHEST_OPEN_WAIT_DURATION)
	tween.tween_callback(ChestPopup.show_rewards)
	tween.tween_callback(clear)


func _get_charitable_amount() -> int:
	return 5
