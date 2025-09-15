@tool
extends Item

# ==============================================================================
const DURATION_SEC := 5
# ==============================================================================

func _use() -> void:
	create_status(Status).set_seconds(DURATION_SEC).set_joined().start()


class Status extends StatusEffect:
	func _load() -> void:
		get_quest().get_stats().get_effects().take_damage.connect(_damage)
	
	func _end() -> void:
		get_quest().get_stats().get_effects().take_damage.disconnect(_damage)
	
	func _damage(amount: int, _source: Object) -> int:
		return amount - get_duration()
