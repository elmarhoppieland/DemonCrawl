extends MasteryUnlocker
class_name BarbarianUnlocker

# ==============================================================================
@export var strangers_killed := 0
# ==============================================================================

func _ready() -> void:
	get_quest().get_stage_effects().object_killed.connect(_object_kill)


func _quest_win() -> void:
	if strangers_killed >= 5:
		unlock(1)
	if strangers_killed >= 10:
		unlock(2)
	if strangers_killed >= 30:
		unlock(3)


func _is_quest_export() -> bool:
	return Codex.get_unlocked_mastery_level(Barbarian) < 3 and strangers_killed > 0


func _object_kill(object: CellObject) -> void:
	if object is Stranger:
		strangers_killed += 1
