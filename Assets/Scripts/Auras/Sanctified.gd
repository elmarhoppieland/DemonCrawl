@tool
extends Aura
class_name Sanctified

# ==============================================================================

func _ready() -> void:
	Quest.get_current().get_stats().get_mutable_effects().life_restore.connect(_restore_life)


func _spawn() -> void:
	Quest.get_current().get_attributes().morality += 1


func _exit_tree() -> void:
	Quest.get_current().get_stats().get_mutable_effects().life_restore.disconnect(_restore_life)


func _get_modulate() -> Color:
	return Color(0.939394, 0.72093, 0.28, 1)


func _restore_life(life: int, _source: Object) -> int:
	if get_cell().is_occupied():
		return life + 1
	return life
