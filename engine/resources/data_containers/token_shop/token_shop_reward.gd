@abstract
extends Resource
class_name TokenShopReward

# ==============================================================================

func apply() -> void:
	_apply()


## Virtual method. Called when the player purchases this [TokenShopReward].
## [br][br][b]Note:[/b] This method is only called once when it is purchased.
## If this [TokenShopReward] needs to reapply its reward each time the profile
## is loaded, override [method _reapply].
@abstract func _apply() -> void


func reapply() -> void:
	_reapply()


## Virtual method. Called when a profile is loaded that has this [TokenShopReward]
## purchased. Should reapply its reward.
func _reapply() -> void:
	pass
