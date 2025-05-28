@tool
extends TokenShopItemBase
class_name TokenShopItem

# ==============================================================================
@export var name := ""
@export_multiline var description := ""
@export var icon: Texture2D = null
@export var cost := 0
@export var reward_script: Script = null
@export var conditions: Array[Condition] = []
@export var unlock_conditions: Array[Condition] = []
# ==============================================================================

func _get_display_name() -> String:
	return name


func _get_description() -> String:
	return description


func _get_icon() -> Texture2D:
	return icon


func _get_cost() -> int:
	return cost


func _get_reward_script() -> Script:
	return reward_script


func _is_visible() -> bool:
	for condition in unlock_conditions:
		if not condition.is_met():
			return false
	
	return true


func _is_locked() -> bool:
	for condition in conditions:
		if not condition.is_met():
			return true
	
	return false
