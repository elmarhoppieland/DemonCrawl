@tool
extends TokenShopReward
class_name TokenShopScriptReward

# ==============================================================================
@export var reward_script: Script = null :
	set(value):
		var different := value != reward_script
		reward_script = value
		if different:
			instance = null
# ==============================================================================
var instance: TokenShopReward = null :
	get:
		if not instance:
			instance = reward_script.new()
		return instance
# ==============================================================================

func _apply() -> void:
	instance.apply()


func _reapply() -> void:
	instance.reapply()
