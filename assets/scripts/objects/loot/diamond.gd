@tool
extends Loot
class_name Diamond

# ==============================================================================
const GLOW_MATERIAL := preload("res://assets/scripts/objects/loot/magic_glow.tres")
const ANIM_DURATION := 0.4
# ==============================================================================

func _get_name_id() -> String:
	return "object.diamond"


func _get_texture() -> AnimatedTextureSequence:
	var texture = AnimatedTextureSequence.new()
	texture.atlas = preload("res://assets/sprites/diamond.png")
	texture.duration = ANIM_DURATION
	return texture


func _get_material() -> Material:
	return GLOW_MATERIAL


func _collect() -> bool:
	var value: int = EffectManager.propagate_mutable((get_stage_instance().get_event_bus(DiamondEffects) as DiamondEffects).get_diamond_value, 1, self, 5)
	get_stats().coins += value
	
	get_cell().add_text_particle("+" + str(value), TextParticles.ColorPreset.COINS)
	
	tween_texture_to(GuiLayer.get_statbar().get_coin_position())
	
	return true


func _get_charitable_amount() -> int:
	return 5


func _is_charitable() -> bool:
	return true


func _can_interact() -> bool:
	return true


class DiamondEffects extends EventBus:
	signal get_diamond_value(diamond: Diamond, value: int)
