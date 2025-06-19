@tool
extends Item

# ==============================================================================
const DURATION_SEC := 300
# ==============================================================================

func _use() -> void:
	create_status(Status).set_seconds(DURATION_SEC).set_joined().start()


class Status extends StatusEffect:
	func _load() -> void:
		var stage: StageInstance = null
		var promise := Promise.new([StageInstance.current_changed, finished])
		while not is_finished():
			if stage:
				stage.get_timer().unblock(self)
				stage = null
			
			if not StageInstance.has_current() or quest != Quest.get_current():
				await promise.any()
				continue
			
			stage = StageInstance.get_current()
			stage.get_timer().block(self)
			
			await promise.any()
		
		if stage:
			stage.get_timer().unblock(self)
