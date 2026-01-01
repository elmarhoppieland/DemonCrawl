@abstract
extends Resource
class_name StageTemplateBase

# ==============================================================================

func generate() -> StageBase:
	return _generate()


@abstract func _generate() -> StageBase
