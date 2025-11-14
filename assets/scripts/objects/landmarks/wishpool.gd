@tool
extends Landmark
class_name Wishpool

# ==============================================================================

var reward: WishpoolReward
var charges: int = 1
var charge_cell_count: int = 0

# ==============================================================================

func _init():
	# TODO: Research actual ranges of wishpool charge count
	charge_cell_count = randi_range(20, 30)


func _spawn():
	var script: Script = null
	while not script:
		script = load("res://assets/loot_tables/wishpool_rewards.tres").generate()
	
	reward = script.new(self)
	reward.notify_spawned()

func _can_interact() -> bool:
	return true
