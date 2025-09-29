@tool
extends TokenShopReward

# ==============================================================================

func _apply() -> void:
	Codex.add_profile_slot()
