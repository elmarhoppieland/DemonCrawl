@tool
@abstract
extends CellObject
class_name Landmark

# ==============================================================================

func _interact() -> void:
	pass

func get_quest() -> Quest:
	var base := get_parent()
	while base != null and base is not Quest:
		base = base.get_parent()
	return base
