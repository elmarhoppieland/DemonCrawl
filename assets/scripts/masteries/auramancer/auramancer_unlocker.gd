@abstract
extends MasteryUnlocker
class_name AuramancerUnlocker

# ==============================================================================

func _enable() -> void:
	get_quest().get_stage_effects().completed.connect(_stage_completed)


func _disable() -> void:
	get_quest().get_stage_effects().completed.disconnect(_stage_completed)


func _stage_completed() -> void:
	var aura_counts: Dictionary[Script, int] = {}
	
	for aura in DemonCrawl.get_full_registry().auras:
		aura_counts[aura] = 0
	
	for cell in get_quest().get_current_stage().get_cells():
		if cell.has_aura():
			aura_counts[cell.get_aura().get_script()] += 1
	
	var count: int = aura_counts.values().min()
	if count >= 1:
		unlock(1)
	if count >= 5:
		unlock(2)
	if count >= 10:
		unlock(3)
