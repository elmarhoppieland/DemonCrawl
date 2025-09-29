@tool
extends TokenShopReward

# ==============================================================================

func _apply() -> void:
	Codex.favored_items.append(null)
