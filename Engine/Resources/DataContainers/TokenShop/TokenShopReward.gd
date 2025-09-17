@abstract
extends Resource
class_name TokenShopReward

# ==============================================================================

func apply() -> void:
	_apply()


@abstract func _apply() -> void


func reapply() -> void:
	_reapply()


func _reapply() -> void:
	pass
