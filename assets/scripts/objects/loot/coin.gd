@tool
extends Loot
class_name Coin

# ==============================================================================
const ANIM_DURATION := 0.4
# ==============================================================================

func _get_texture() -> AnimatedTextureSequence:
	var texture := AnimatedTextureSequence.new()
	texture.atlas = preload("res://assets/sprites/coin.png")
	texture.duration = ANIM_DURATION
	return texture


func _get_palette() -> CompressedTexture2D:
	return get_theme_icon("coin_palette", "Cell")


func _collect() -> bool:
	var value: int = EffectManager.propagate_mutable((get_quest().get_event_bus(CoinEffects) as CoinEffects).get_coin_value, 1, self, 1)
	get_stats().coins += value
	
	get_cell().add_text_particle("+" + str(value), TextParticles.ColorPreset.COINS)
	
	tween_texture_to(GuiLayer.get_statbar().get_coin_position())
	
	return true


func _get_charitable_amount() -> int:
	return 1


func _is_charitable() -> bool:
	return true


func _can_interact() -> bool:
	return true


class CoinEffects extends EventBus:
	signal get_coin_value(coin: Coin, value: int)
