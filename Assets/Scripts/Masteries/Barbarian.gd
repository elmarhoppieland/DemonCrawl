@tool
extends Mastery
class_name Barbarian

# ==============================================================================

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
	
	# TODO: activate Rotting Head
	Toasts.add_toast("Activated Rotting Head", create_icon())
