@abstract
extends Resource
class_name WishpoolReward

# ==============================================================================
var _wishpool: Wishpool
var reward_per_charge: int
@export var reward_range: Array[int]
# ==============================================================================

func _init(wishpool: Wishpool = null) -> void:
	_wishpool = wishpool


func _spawn() -> void:
	reward_per_charge = randi_range(reward_range[0], reward_range[1])


func notify_spawned() -> void:
	_spawn()


## Virtual method to override the return value of [method get_description].
func _get_description() -> String:
	var values := {}
	for prop in get_property_list():
		if not prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			continue
		values[prop.name] = tr(str(get(prop.name)))
	
	return tr("landmark.wishpool." + _get_script_name().to_snake_case().to_lower().replace("_", ".")).format(values)


## Returns the Wishpool's description.
func get_description() -> String:
	return _get_description()


@abstract func _perform() -> void


func perform() -> void:
	_perform()


func _get_script_name() -> String:
	return UserClassDB.script_get_class(get_script()).trim_prefix("Wishpool").trim_suffix("Reward")
