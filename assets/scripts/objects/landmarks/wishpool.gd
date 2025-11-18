@tool
extends Landmark
class_name Wishpool

# ==============================================================================
var reward: WishpoolReward
var charges: int
var charge_cell_count: int
var local_cells_since_last_mistake: int
# ==============================================================================
const GLOW_MATERIAL = preload("res://assets/scripts/objects/landmarks/magic_glow.tres")
# ==============================================================================

func _init():
	# TODO: Research actual ranges of wishpool charge count
	charge_cell_count = randi_range(20, 30)
	charges = 1
	local_cells_since_last_mistake = 0


func _spawn():
	var script: WishpoolReward = null
	while not script:
		script = load("res://assets/loot_tables/wishpool_rewards.tres").generate()
	
	reward = script
	reward.init(self)
	reward.notify_spawned()


func _get_material() -> Material:
	return GLOW_MATERIAL


func _enter_tree() -> void:
	if get_parent() is not CellData:
		return
	
	get_quest().get_attributes().property_changed.connect(_attribute_changed)


func _exit_tree() -> void:
	if get_parent() is not CellData:
		return
	
	get_quest().get_attributes().property_changed.disconnect(_attribute_changed)


func _attribute_changed(attribute: StringName, value: Variant) -> void:
	if attribute == &"cells_opened_since_last_mistake":
		_cells_opened_since_last_mistake_changed(value)


func _cells_opened_since_last_mistake_changed(cell_count: int) -> void:
	if cell_count == 0:
		local_cells_since_last_mistake = 0
		return
	
	local_cells_since_last_mistake += cell_count - get_quest().get_attributes().cells_opened_since_mistake
	
	if local_cells_since_last_mistake >= charge_cell_count:
		charges += local_cells_since_last_mistake / charge_cell_count
		local_cells_since_last_mistake = local_cells_since_last_mistake % charge_cell_count


func _can_interact() -> bool:
	return true


func _interact() -> void:
	reward.perform()
	
	# Shrink to nothing
	
	clear()


func _get_annotation_subtext() -> String:
	var values = {
		"total_reward": charges * reward.reward_per_charge,
		"reward_per_charge": reward.reward_per_charge,
		"charge_cell_count": charge_cell_count
	}
	
	return (tr("landmark.wishpool." + reward.get_script_name().to_snake_case()) + " " + tr("landmark.wishpool.increase")).format(values)
