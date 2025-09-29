@tool
extends TokenShopReward

# ==============================================================================

func _apply() -> void:
	Codex.add_heirloom_slot()
