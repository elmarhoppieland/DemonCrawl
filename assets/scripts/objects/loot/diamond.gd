@tool
extends Loot
class_name Diamond

# ==============================================================================
var glow_material := load("res://assets/scripts/objects/loot/magic_glow.tres")
# ==============================================================================

func _get_texture() -> CompressedTexture2D:
	return preload("res://assets/sprites/diamond.png")


func _get_material() -> Material:
	glow_material.set_shader_parameter(&"Speed", 8.0)
	return glow_material


func _collect() -> bool:
	var value: int = EffectManager.propagate_mutable((get_quest().get_event_bus(DiamondEffects) as DiamondEffects).get_diamond_value, 1, self, 5)
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
