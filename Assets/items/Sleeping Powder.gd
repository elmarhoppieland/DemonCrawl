@tool
extends Item

# ==============================================================================
const DURATION_SEC := 300
# ==============================================================================

func use() -> void:
	#for status in StatusEffectsOverlay.get_status_effects():
		#if status.attribute is Status:
			#status.duration += DURATION_SEC
			#status.origin += DURATION_SEC
			#clear()
			#return
	
	#create_status().set_seconds(DURATION_SEC).set_attribute(Status.new()).start()
	clear()


#class Status:
	#func _init() -> void:
		#Board.pause_timer()
		#Effects.Signals.board_permissions_changed.connect(board_permissions_changed)
	#
	#func board_permissions_changed() -> void:
		#if Board.exists():
			#Board.pause_timer()
	#
	#func end() -> void:
		#if Board.exists() and Board.can_run_timer():
			#Board.resume_timer()
