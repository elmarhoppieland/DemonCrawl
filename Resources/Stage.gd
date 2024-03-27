extends RefCounted
class_name Stage

## A single stage in a quest.

# ==============================================================================
var name := "" ## The name of the stage.
var size := Vector2i.ZERO ## The size of the stage.
var monsters := 0 ## The number of monsters in the stage.
var min_power := 0 ## The stage's minimum power.
var max_power := 0 ## The stage's maximum power.

var locked := false ## Whether the stage is locked.
# ==============================================================================

func _init(_name: String = "", _size: Vector2i = Vector2i.ZERO, _monsters: int = 0) -> void:
	name = _name
	size = _size
	monsters = _monsters
