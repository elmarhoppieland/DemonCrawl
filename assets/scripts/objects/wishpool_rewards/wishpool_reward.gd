@abstract
extends Resource
class_name WishpoolReward

# ==============================================================================
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE) var _wishpool: Wishpool
@export var reward_per_charge: int
# ==============================================================================

func init(wishpool: Wishpool = null) -> void:
	_wishpool = wishpool


@abstract func _perform() -> void


func perform() -> void:
	_perform()


func get_script_name() -> String:
	return UserClassDB.script_get_class(get_script()).trim_prefix("Wishpool").trim_suffix("Reward")
