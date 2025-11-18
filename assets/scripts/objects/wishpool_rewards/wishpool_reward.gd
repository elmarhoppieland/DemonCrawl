@abstract
extends Resource
class_name WishpoolReward

# ==============================================================================
var _wishpool: Wishpool
var reward_per_charge: int
@export var reward_min: int
@export var reward_max: int
# ==============================================================================

func init(wishpool: Wishpool = null) -> void:
	_wishpool = wishpool


func _spawn() -> void:
	reward_per_charge = randi_range(reward_min, reward_max)


func notify_spawned() -> void:
	_spawn()


@abstract func _perform() -> void


func perform() -> void:
	_perform()


func get_script_name() -> String:
	return UserClassDB.script_get_class(get_script()).trim_prefix("Wishpool").trim_suffix("Reward")
