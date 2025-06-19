@tool
extends Mastery
class_name Barbarian

# ==============================================================================
const ROTTING_HEAD := preload("res://Assets/Items/Rotting Head.tres")
# ==============================================================================
var strangers_killed := 0
# ==============================================================================

func _get_export_properties() -> PackedStringArray:
	if level < 3 or strangers_killed == 0:
		return []
	return ["strangers_killed"]


func _quest_load() -> void:
	Effects.Signals.object_interacted.connect(_object_interact)
	Effects.Signals.object_killed.connect(_object_kill)


func _object_interact(object: CellObject) -> void:
	if not object is Stranger:
		return
	if level < 1:
		return
	
	if not (object as Stranger).can_afford():
		object.kill()


func _object_kill(object: CellObject) -> void:
	if not object is Stranger:
		return
	if level < 2:
		return
	
	ROTTING_HEAD.invoke()
	
	if level < 3:
		return
	
	strangers_killed += 1


func _ability() -> void:
	ROTTING_HEAD.create_status(ROTTING_HEAD.Status).set_seconds(ROTTING_HEAD.DURATION_SEC * strangers_killed).set_joined().start()


func _get_max_charges() -> int:
	return 3
