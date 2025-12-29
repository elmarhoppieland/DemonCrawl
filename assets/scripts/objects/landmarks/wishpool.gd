@tool
extends Landmark
class_name Wishpool

# ==============================================================================
const FLASH_MATERIAL := preload("res://assets/scripts/objects/landmarks/flash.tres")
const CHARGE_CELL_COUNT := 30
# ==============================================================================
var reward: WishpoolReward
var charges: int
# ==============================================================================

func _get_name_id() -> String:
	return "object.wishpool"


func _spawn():
	while not reward:
		reward = load("res://assets/loot_tables/wishpool_rewards.tres").generate()
	charges = 1

	reward.init(self)


func _get_material() -> Material:
	return FLASH_MATERIAL


func _enter_tree() -> void:
	if get_parent() is not CellData or get_cell().is_hidden():
		return
	
	get_quest().get_attributes().property_changed.connect(_attribute_changed)


func _exit_tree() -> void:
	if get_quest().get_attributes().property_changed.is_connected(_attribute_changed):
		get_quest().get_attributes().property_changed.disconnect(_attribute_changed)


func _reveal() -> void:
	get_quest().get_attributes().property_changed.connect(_attribute_changed)


func _attribute_changed(attribute: StringName, value: Variant) -> void:
	if attribute == &"cells_opened_since_mistake":
		_cells_opened_since_mistake_changed(value)


func _cells_opened_since_mistake_changed(cell_count: int) -> void:
	if cell_count == 0:
		return
	
	var change := cell_count % CHARGE_CELL_COUNT - get_quest().get_attributes().cells_opened_since_mistake % CHARGE_CELL_COUNT
	
	if change > 0:
		charges += change
		Toasts.add_toast(tr("object.wishpool.shimmer"), _get_texture())


func _can_interact() -> bool:
	return true


func _interact() -> void:
	if charges == 0:
		Toasts.add_toast(tr("object.wishpool.empty"), _get_texture())
		return
	
	reward.perform()
	Toasts.add_toast(tr("object.wishpool.collect"), _get_texture())
	
	flee()


func _get_annotation_subtext() -> String:
	var values := {
		"total_reward": charges * reward.reward_per_charge,
		"reward_per_charge": reward.reward_per_charge,
		"charge_cell_count": CHARGE_CELL_COUNT
	}
	
	return (tr("object.wishpool." + reward.get_script_name().to_snake_case()) + " " + tr("object.wishpool.increase")).format(values)
