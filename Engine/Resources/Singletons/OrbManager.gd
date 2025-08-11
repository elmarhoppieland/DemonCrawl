@tool
extends Node
class_name OrbManager

# ==============================================================================
@export var orb_speed := 32.0
# ==============================================================================
signal orb_registered(orb: Orb, global_position: Vector2)
# ==============================================================================

func get_quest() -> Quest:
	var base := get_parent()
	while base != null and base is not Quest:
		base = base.get_parent()
	return base


func _init() -> void:
	name = "OrbManager"


func register_orb(orb: Orb, global_position: Vector2 = orb.position) -> void:
	add_child(orb)
	
	orb_registered.emit(orb, global_position)


func get_orbs() -> Array[Orb]:
	var orbs: Array[Orb] = []
	orbs.assign(get_children())
	return orbs
