@tool
extends Book

# ==============================================================================
const START_DURATION := 333
const EXTEND_DURATION := 50
# ==============================================================================
@export var status: Status = null
# ==============================================================================

func _gain() -> void:
	status = create_status(Status).set_turns(START_DURATION).start()


func _activate() -> void:
	if not status:
		Debug.log_error("Book of Faith needs a status effect to work.")
		return
	
	status.duration += EXTEND_DURATION


class Status extends StatusEffect:
	func _finish() -> void:
		if source is Item:
			source.clear()
		else:
			Debug.log_error("Book of Faith's status effect only works when the source is an Item, but %s was found." % (UserClassDB.script_get_identifier(source.get_script()) if source else &"Nil"))
