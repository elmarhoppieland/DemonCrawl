extends Orb
class_name Bubble

# ==============================================================================
const BUBBLE_SPRITE := preload("res://Assets/Scripts/Orbs/BubbleSprite.tscn")
# ==============================================================================
@export var object: CellObject = null
# ==============================================================================

@warning_ignore("shadowed_variable")
func _init(object: CellObject = null) -> void:
	self.object = object


func _export_packed() -> Array:
	return [object]


func _create_sprite() -> BubbleSprite:
	return BUBBLE_SPRITE.instantiate()
