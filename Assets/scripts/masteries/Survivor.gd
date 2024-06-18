extends Mastery

# ==============================================================================

func quest_start() -> void:
	if level < 1:
		return
	Stats.max_life += 1


func stage_end(stage: Stage) -> void:
	if level < 2:
		return
	
	if Stats.life < Stats.max_life:
		Stats.max_life += stage.min_power


func ability() -> void:
	for i in Stats.max_life - Stats.life:
		Board.solve_cell()
	
	Stats.life = Stats.max_life
