@tool
extends Book

# ==============================================================================
const COIN_GAIN_AMOUNT := 10
# ==============================================================================

func _activate() -> void:
	get_stats().gain_coins(COIN_GAIN_AMOUNT, self)
