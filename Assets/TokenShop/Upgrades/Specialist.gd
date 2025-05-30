@tool
extends TokenShopReward
class_name Specialist

# ==============================================================================

func _apply() -> void:
	Codex.favored_items.append(null)
