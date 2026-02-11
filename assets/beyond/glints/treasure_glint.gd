extends Glint

# ==============================================================================

func _enable() -> void:
	get_quest().get_stage_effects().get_guaranteed_objects.connect(_get_guaranteed_objects)


func _disable() -> void:
	get_quest().get_stage_effects().get_guaranteed_objects.disconnect(_get_guaranteed_objects)


func _get_guaranteed_objects(_stage: StageInstance, objects: Array[CellObject]) -> Array[CellObject]:
	objects.append_array([
		Token.new(),
		TreasureChest.new(),
		TreasureChest.new(),
		Diamond.new(),
		Diamond.new(),
		Diamond.new()
	])
	return objects
