@tool
extends Item

# ==============================================================================
const DURATION_SEC := 300
# ==============================================================================

func _use() -> void:
	create_status(Status).set_seconds(DURATION_SEC).set_joined().start()


class Status extends StatusEffect:
	func _enter_tree() -> void:
		var stage: StageInstance = null
		var promise := Promise.new([get_quest().current_stage_changed, finished])
		while not is_finished():
			if stage:
				stage.get_timer().unblock(self)
				stage = null
			
			if not get_quest().has_current_stage():
				await promise.any()
				continue
			
			stage = get_quest().get_current_stage()
			stage.get_timer().block(self)
			
			await promise.any()
		
		if stage:
			stage.get_timer().unblock(self)
