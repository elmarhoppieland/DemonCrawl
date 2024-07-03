extends Item

# ==============================================================================
const DURATION_SEC := 300
# ==============================================================================

func use() -> void:
	if StatusEffectsOverlay.has_status_effect(get_id()):
		StatusEffectsOverlay.get_status_effect(get_id()).count += DURATION_SEC
	else:
		create_status().set_seconds(DURATION_SEC).set_object(Status.new()).start()
	
	clear()


func recreate_status(duration: int) -> StatusEffect:
	return create_status().set_seconds(duration).set_origin_count(DURATION_SEC).set_object(Status.new()).start()


func get_id() -> String:
	return (get_script() as Script).resource_path


class Status:
	func start() -> void:
		Board.saved_time = Board.get_timef()
		Board.start_time = -1
	
	func end() -> void:
		Board.start_time = Time.get_ticks_usec()
