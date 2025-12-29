@abstract
extends Resource
class_name StageFileBase

# ==============================================================================

func generate() -> StageBase:
	return _generate()


@abstract func _generate() -> StageBase
