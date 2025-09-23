@tool
extends Book

# ==============================================================================
const MANA_GAIN_AMOUNT := 100
# ==============================================================================

func _activate() -> void:
	get_inventory().mana_gain(MANA_GAIN_AMOUNT, self)
