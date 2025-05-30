@tool
extends TokenShopReward
class_name TokenShopScriptReward

# ==============================================================================
@export var reward_script: Script = null
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
