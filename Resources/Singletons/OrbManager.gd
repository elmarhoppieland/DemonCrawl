@tool
extends Resource
class_name OrbManager

# ==============================================================================
@export var orbs: Array[Orb] = []
@export var orb_speed := 32.0
# ==============================================================================
signal orb_registered(orb: Orb, global_position: Vector2)
# ==============================================================================

func register_orb(orb: Orb, global_position: Vector2 = Vector2.ZERO) -> void:
	if orb not in orbs:
		orbs.append(orb)
	
	orb_registered.emit(orb, global_position)
