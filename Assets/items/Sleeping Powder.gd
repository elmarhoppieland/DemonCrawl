extends Item

# ==============================================================================
const DURATION_SEC := 300
# ==============================================================================
static var uid := "" :
	get:
		if uid.is_empty():
			uid = StatusEffectsOverlay.create_id()
		return uid
# ==============================================================================

func use() -> void:
	if StatusEffectsOverlay.has_id(uid):
		StatusEffectsOverlay.get_status_effect(uid).duration += DURATION_SEC
	else:
		create_status(uid).set_seconds(DURATION_SEC).set_attribute(Status.new()).set_source(self).start()
	
	clear()


class Status:
	func _init() -> void:
		Board.pause_timer()
		EffectManager.connect_effect(func board_permissions_changed() -> void: Board.pause_timer())
	
	func end() -> void:
		Board.resume_timer()
