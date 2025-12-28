@tool
extends Aura
class_name Burning

# ==============================================================================

func _get_name_id() -> String:
	return "aura.burning"


func _get_modulate() -> Color:
	return Color("#b2482f")


func _interact() -> void:
	negative_effect(Quest.get_current().get_stats().life_lose.bind(1, self))


func _is_elemental() -> bool:
	return true
