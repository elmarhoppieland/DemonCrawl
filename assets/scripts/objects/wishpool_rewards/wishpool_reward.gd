@abstract
extends Resource
class_name WishpoolReward

# ==============================================================================
var _wishpool: Wishpool
@export var reward_per_charge: int
# ==============================================================================

func init(wishpool: Wishpool = null) -> void:
	_wishpool = wishpool


@abstract func _perform() -> void


func perform() -> void:
	_perform()


func get_script_name() -> String:
	return UserClassDB.script_get_class(get_script()).trim_prefix("Wishpool").trim_suffix("Reward")
